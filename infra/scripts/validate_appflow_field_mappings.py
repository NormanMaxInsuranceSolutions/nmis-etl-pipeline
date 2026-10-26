# Alejandro @10/26/2026 NMIS-2131 Validate explicit AppFlow field mappings against each environment
"""
Checks that every field in AppFlow flows with a fixed field list is visible
through its Salesforce connection, so a build stops before apply instead of
flows failing with INVALID_FIELD at runtime.

Usage: python3 validate_appflow_field_mappings.py <terraform plan json>
"""
import json
import subprocess
import sys


def planned_flows(plan):
    """Returns flows with a fixed field list, plus a readable error for each flow whose plan data could not be read."""
    flows, errors = [], []
    for change in plan.get("resource_changes", []):
        after = (change.get("change") or {}).get("after")
        if change.get("type") != "aws_appflow_flow" or not after:
            continue

        address = change.get("address", "unknown resource")
        step = "source_flow_config"
        try:
            source = after["source_flow_config"][0]
            step = "source_connector_properties.salesforce"
            salesforce = source["source_connector_properties"][0].get("salesforce") or []
            step = "task (task_type, connector_operator, source_fields)"
            fields = [
                field
                for task in after.get("task", [])
                if task["task_type"] == "Filter" and task["connector_operator"][0].get("salesforce") == "PROJECTION"
                for field in task["source_fields"]
            ]
            step = "name and salesforce.object"
            if salesforce and fields:
                flows.append((after["name"], source.get("connector_profile_name"), salesforce[0]["object"], fields))
        except (KeyError, IndexError, TypeError) as error:
            errors.append(f"{address}: could not read {step} from Terraform plan ({type(error).__name__}: {error})")
    return flows, errors


def visible_fields(connector_profile, entity):
    """Returns field names Salesforce exposes to connection's integration user."""
    result = subprocess.run(
        [
            "aws", "appflow", "describe-connector-entity",
            "--connector-entity-name", entity,
            "--connector-type", "Salesforce",
            "--connector-profile-name", connector_profile,
            "--output", "json",
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    try:
        return {field["identifier"] for field in json.loads(result.stdout)["connectorEntityFields"]}
    except (json.JSONDecodeError, KeyError, TypeError) as error:
        raise RuntimeError(f"unexpected describe-connector-entity response ({type(error).__name__}: {error})")


def main():
    if len(sys.argv) != 2:
        sys.exit("Usage: python3 validate_appflow_field_mappings.py <terraform plan json>")

    try:
        with open(sys.argv[1]) as plan_file:
            plan = json.load(plan_file)
    except (OSError, json.JSONDecodeError) as error:
        sys.exit(f"Could not read Terraform plan JSON {sys.argv[1]}: {error}")

    flows, failures = planned_flows(plan)
    entities = {}
    for flow, connector_profile, entity, fields in flows:
        if not connector_profile:
            print(f"{flow}: connector profile not known at plan time, skipped")
            continue

        key = (connector_profile, entity)
        try:
            if key not in entities:
                entities[key] = visible_fields(connector_profile, entity)
        except RuntimeError as error:
            failures.append(f"{flow}: could not describe {entity} through {connector_profile}: {error}")
            continue

        missing = sorted(set(fields) - entities[key])
        print(f"{flow}: {len(fields)} fields checked, {len(missing)} missing")
        if missing:
            failures.append(f"{flow} ({entity}): fields not visible to Salesforce integration user: {', '.join(missing)}")

    if failures:
        print("AppFlow field mapping validation failed:")
        for failure in failures:
            print(f"  {failure}")
        sys.exit(1)


if __name__ == "__main__":
    main()
