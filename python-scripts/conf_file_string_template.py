import string
values = { 'param_1':'homer','param_2':'bart','param_3':'lisa','s1_par_1':'10','s1_par_2':'30' }
t = string.Template("""
## Sample config file for app_a
[main]
    parameter_1 = $param_1
    parameter_2 = $param_2
    parameter_3 = $param_3
    
[section-1]
    parameter_1 = $s1_par_1
    parameter_2 = $s1_par_2
""")
print'TEMPLATE:', t.substitute(values)


demo_txt = '''
Text_ln_1: %homer
Text_ln_2: %bart
'''

d = {'homer':'HomeR'}

class CusTemplate(string.Template):
    delimiter = '%'
    idpattern = 'homer'
e = CusTemplate(demo_txt)

print e.safe_substitute(d)	