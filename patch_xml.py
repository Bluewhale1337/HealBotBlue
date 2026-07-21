import re

with open('HealBot_Action.xml', 'r') as f:
    content = f.read()

buttons_42_50 = '\n'.join([f'      <Button name=\"HealBot_Action_HealUnit{i}\" inherits=\"HealingButtonTemplate\" text=\"Unit not set\"/>' for i in range(42, 51)])
buttons_61_100 = '\n'.join([f'      <Button name=\"HealBot_Action_HealUnit{i}\" inherits=\"HealingButtonTemplate2\" text=\"Unit not set\"/>' for i in range(61, 101)])

content = re.sub(
    r'(<Button name=\"HealBot_Action_HealUnit41\" [^\>]+>\n)',
    r'\g<1>' + buttons_42_50 + '\n',
    content
)

content = re.sub(
    r'(<Button name=\"HealBot_Action_HealUnit60\" [^\>]+>\n)',
    r'\g<1>' + buttons_61_100 + '\n',
    content
)

with open('HealBot_Action.xml', 'w') as f:
    f.write(content)
print('Updated HealBot_Action.xml')
