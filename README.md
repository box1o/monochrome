# Mono

## Project commands

Create a project-local `d.bl.sh`, then define and run project commands:

```bash
d-init
d help
```

Each command is a Bash function named `gblcmd_<name>`. An optional
`gblcmd_descr_<name>` variable supplies its help text. A `d.bl.sh` directory
containing multiple `*.bl.sh` files is also supported.
