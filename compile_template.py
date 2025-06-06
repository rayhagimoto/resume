#!/usr/bin/env python3

import yaml
import jinja2
import os

def main():
    # Load YAML content
    with open('content.yaml', 'r') as f:
        content = yaml.safe_load(f)

    # Set up Jinja2 environment
    env = jinja2.Environment(
        block_start_string=r'\BLOCK{',
        block_end_string=r'}',
        variable_start_string=r'\VAR{',
        variable_end_string=r'}',
        comment_start_string=r'\#{',
        comment_end_string=r'}',
        line_statement_prefix=r'%%',
        line_comment_prefix=r'%#',
        trim_blocks=True,
        autoescape=False,
        loader=jinja2.FileSystemLoader('src')
    )

    # Load and render template
    template = env.get_template('template.tex')
    output = template.render(**content)

    # Ensure src directory exists
    os.makedirs('src', exist_ok=True)

    # Write output to main.tex
    with open('src/main.tex', 'w') as f:
        f.write(output)

if __name__ == '__main__':
    main() 