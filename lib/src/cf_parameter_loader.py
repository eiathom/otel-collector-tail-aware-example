from typing import Any
import sys
import os
import yaml


def get_python_object_from_yaml_file(file_path: str) -> Any:
    with open(file_path, "r") as f:
        return yaml.safe_load(f)


def get_environment_configuration_from_python_object(
    yaml_object: Any, environment: str
) -> Any:
    if environment in yaml_object["environment"]:
        return yaml_object["environment"][environment]


def get_interpreted_environment_configuration(environment_configuration: Any) -> dict:
    interpreted_vars = {}
    for key, value in environment_configuration.items():
        interpreted_vars[key] = get_interpreted_variable_value(value)
    return interpreted_vars


def get_value_from_environment(key: str, default_value: str) -> str:
    value_from_environment = ""
    copied_default_value = default_value.strip()
    value_from_environment = os.getenv(key, copied_default_value)
    if len(value_from_environment.strip()) == 0:
        print(f"WARNING - variable '{key}' value is empty")
    return value_from_environment


def get_interpreted_variable_value(value: str) -> str:
    if isinstance(value, str) and value.startswith("${") and value.endswith("}"):
        environment_variable_key_name, _, default_value = value[2:-1].partition(":")
        return get_value_from_environment(environment_variable_key_name, default_value)
    return value


def get_string_for_cf_parameter_overrides_option(parameters: dict) -> str:
    return " ".join([f"{key}={value}" for key, value in parameters.items()])


if __name__ == "__main__":
    file_path = sys.argv[1]
    environment_name = sys.argv[2]

    configuration = get_python_object_from_yaml_file(file_path)
    environment_configuration = get_environment_configuration_from_python_object(configuration, environment_name)
    interpreted_parameters = get_interpreted_environment_configuration(environment_configuration["parameters"])

    print(get_string_for_cf_parameter_overrides_option(interpreted_parameters))
