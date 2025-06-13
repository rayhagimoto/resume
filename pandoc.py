import yaml
import pypandoc
content = yaml.safe_load("content.yaml")

def md_to_latex(text):
    return pypandoc.convert_text(text, 'latex', format='markdown')

if __name__ == '__main__':
    
    for src in [
        "**MARKDOWN TEXT**",
        "**& $ %**",
        "`this is code`",
        "[rayhagimoto/resume](https://github.com/rayhagimoto/resume)"
    ]:
      out = md_to_latex(src)
      print(out)