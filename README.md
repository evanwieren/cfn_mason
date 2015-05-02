This is a series of utilities to manage Cloud Formation Templates.

The project has some core ideas:

* We are not writing a DSL to wrap Cloud Formation
* Provide a number of small utils that have specific tasks
* Integrate with AWS to allow CFN Stacks to be easily linked
* Parameters should be easy to configure outside of CFN template


CFN Utils Will follow this basic design.

- Environment SPECS Directory/File
    - This file will contain a list of the CFN stacks that are needed in order to build out an environment.
    - Can contain variables
    - Can specify different input params based on environment.
- Cloud Formation Spec
    - Simple yaml file indicating parameters needed
    - Contains Resources
    - Contains mappings
    - Outputs
- CFN Blocks (All in YAML)
    - Parameters
        - Each parameter will have its own building block
    - Mapptings
        - Allows for the mappings to be set by environment
    - Resources