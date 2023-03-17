import os
import yaml
import json
# parse yaml file into array of lua classes

class Skill(yaml.YAMLObject):
    yaml_tag = u'!Skill'
    def __init__(self, dice, powerup, modifiers, text):
        self.powerup = powerup
        self.dice = dice
        self.modifiers = modifiers
        self.text = text

    def __repr__(self):
        return "%s(dice=%r, powerup=%r, modifiers=%r, text=%r)" %(
            self.__class__.__name__, self.dice, self.powerup, self.modifiers, self.text)

def default_ctor(loader, tag_suffix, node):
    return
yaml.add_multi_constructor('', default_ctor)

class SkillEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Skill):
            return vars(obj)
        return super().default(obj)


def get_all_yaml_files_dir_and_subdirs(dir_path):
    yaml_files_dir_and_subdirs = []
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith(".yaml"):
                yaml_files_dir_and_subdirs.append(os.path.join(root, file))
    return yaml_files_dir_and_subdirs

def open_yaml(path):
    with open(path, 'r') as stream:
        try:
            return yaml.full_load(stream)
        except yaml.YAMLError as exc:
            print(exc)

def convert_python_to_lua_array(python_array):
    """
    Convert a Python array to a Lua array in text format.
    """
    # Convert each element of the Python array to a Lua string
    lua_array_elements = []
    for element in python_array:
        if isinstance(element, str):
            lua_array_elements.append("\"" + element + "\"")
        elif isinstance(element, bool):
            lua_array_elements.append(str(element).lower())
        else:
            lua_array_elements.append(str(element))
    
    # Convert the Lua array elements to a Lua array string
    lua_array = "{" + ",".join(lua_array_elements) + "}"
    
    # Return the Lua array string
    return lua_array

def convert_python_to_lua_table(python_dict):
    """
    Convert a Python dictionary to a Lua table in text format.
    """
    # Convert each key-value pair of the Python dictionary to a Lua string
    lua_table_pairs = []
    for key, value in python_dict.items():
        if isinstance(key, str):
            lua_key = "" + key + ""
        else:
            lua_key = str(key)
        if key == "Skill" or key == "Skills":
            continue
        if isinstance(value, dict):
            lua_value = convert_python_to_lua_table(value)
        elif isinstance(value, list):
            lua_value = convert_python_to_lua_array(value)
        elif isinstance(value, str):
            lua_value = "\"" + value + "\""
        elif isinstance(value, bool):
            lua_value = str(value).lower()
        else:
            lua_value = str(value)
        
        lua_table_pairs.append(lua_key + " = " + lua_value)
    
    # Convert the Lua table pairs to a Lua table string
    lua_table = "\t{\n\t\t" + ",".join(lua_table_pairs) + "\n\t}"
    
    # Return the Lua table string
    return lua_table

def parse_yaml_file(yaml_file_path):
    data = open_yaml(path=yaml_file_path)
    output = ""
    for card in data:
        output += convert_python_to_lua_table(card) + ",\n"
    return output
    

def parse_yaml_files_in_folder(folder_path, name):
    yaml_files = get_all_yaml_files_dir_and_subdirs(folder_path)
    yaml_files.sort()
    output = name + " = {\n"
    for yaml_file in yaml_files:
        print(yaml_file)
        output += parse_yaml_file(yaml_file)
    output += "}\n"
    return output

def save_string_into_file(file_path, string):
    with open(file_path, 'w') as f:
        f.write(string)


def convert_yaml_in_directory_to_json(folder_path, name):
    yaml_files = get_all_yaml_files_dir_and_subdirs(folder_path)
    yaml_data = []
    for file in yaml_files: 
        with open(file, 'r') as yaml_file:
            yaml_data.append(yaml.load(yaml_file, Loader=yaml.FullLoader))
    json_data = json.dumps(yaml_data, cls=SkillEncoder)
    
    with open(name + '.json', 'w') as json_file:
        json_file.write(json_data)

#convert_yaml_in_directory_to_json("/home/simon/Projects/CreatureCardsConverter/data/abilities_new_format", "abilities")
#convert_yaml_in_directory_to_json("/home/simon/Projects/CreatureCardsConverter/data/creatures", "creatures")
#convert_yaml_in_directory_to_json("/home/simon/Projects/CreatureCardsConverter/data/mutations", "mutations")


abilities = parse_yaml_files_in_folder("../data/abilities_new_format", "Abilities")
save_string_into_file("./abilities.lua", abilities)
creatures = parse_yaml_files_in_folder("../data/creatures", "Creatures")
save_string_into_file("./creatures.lua", creatures)
mutations = parse_yaml_files_in_folder("../data/mutations", "Mutations")
save_string_into_file("./mutations.lua", mutations)
