import os
import yaml
import xml.etree.ElementTree as ET
import subprocess
import re
from svg_card_creator import svg_card_creator as CC
from svg_card_creator import svg_writer_helpers as svg_h

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

unicodeDiceMap = {"1": "\ue805", "2": "\ue804", "3": "\ue803", "4": "\ue802", "5": "\ue801", "6": "\ue800", "X" : "\ue831",
                  "M2": "\ue806", "M3" : "\ue910", "M4" : "\ue809", "M5": "\ue808", "M": "\ue832",
                  "S2": "\ue814", "S3": "\ue813", "S4": "\ue812", "S5": "\ue811", "S": "\ue80c"}

powerupDiceMap = {1: "\ue830", 2: "\ue82f", 3: "\ue82e", 4: "\ue82d", 5: "\ue82c", 6: "\ue82b", 7: "\ue82a", 8: "\ue829", 9: "\ue828",
                  10: "\ue827", 11: "\ue826", 12: "\ue825", 13: "\ue824", 14: "\ue823", 15: "\ue822", 16: "\ue821", 17: "\ue820",
                  18: "\ue81f", 19: "\ue81e", 20: "\ue81d", 21: "\ue81c"}

def getCodeFromMatch(match):
    if(match[0][2] == "D"):
        return unicodeDiceMap[(match[0][4])]
    return "bullshit"

def substituteIconsInText(text):
    pattern = r"\{\{\w+:\w+\}\}"
    return re.sub(pattern, getCodeFromMatch, text)

def parseAndApplySkillText(skill, element):
    text = ""
    if skill.powerup != None:
        text += powerupDiceMap[skill.powerup]
    if skill.dice != None:
        for dice in skill.dice:
            text += unicodeDiceMap[str(dice)]

    element.set("alignment-baseline", "middle")
    ET.SubElement(element, "ns0:tspan", {"alignment-baseline": "baseline",
        "style": "font-size:44px;font-family:zvery-icons;-inkscape-font-specification:fontello;", "id": "coole-id"})

    smallElementDict = {"alignment-baseline": "middle", "style": "font-size:28px;font-family:zvery-icons, sans-serif;-inkscape-font-specification:fontello;", "id": "coole-id"}

    element.attrib["style"] +=  ";dominant-baseline: central;"
    element[0].text = ""
    element[1].text = text
    index = 2
    if skill.modifiers != None:
        ET.SubElement(element, "ns0:tspan", smallElementDict)
        element[index].attrib["style"] += ";font-weight: bold;"
        element[index].text = " " + (', ').join(skill.modifiers) + "."
        index += 1
    ET.SubElement(element, "ns0:tspan", smallElementDict)
    skillText = " " + substituteIconsInText(skill.text)
    element[index].text = skillText


yaml.add_multi_constructor('', default_ctor)

def returnMutationTemplate(mutation):
    if mutation["Mutation"] == "Skill":
        return "./ivan-svg-templates/mutation-upgrade-templates/mutation_skill_" + mutation["Type"].lower() + ".svg"
    elif mutation["Mutation"] == "Upgrade":
        return "./ivan-svg-templates/mutation-upgrade-templates/mutation_upgrade_" + mutation["Type"].lower() + ".svg"
    elif mutation["Mutation"] == "Augment":
        return "./ivan-svg-templates/mutation-upgrade-templates/mutation_augment_" + mutation["Type"].lower() + ".svg"

def get_template_path_from_card(card):
    if card["CardType"] == "creature":
        return "./ivan-svg-templates/creature-templates/" + card["Type"].lower() + "-creature-template.svg"
    elif card["CardType"] == "mutation":
        return returnMutationTemplate(card)
    elif card["CardType"] == "adaptation":
        return "./ivan-svg-templates/adaptation-templates/adaptation_" + card["Type"].lower()  + ".svg"

def set_mutation_text(element, mutation):
    if "Skill" in mutation and mutation["Skill"] != None:
        parseAndApplySkillText(mutation["Skill"], element)
    else:
        svg_h.set_svg_element_text(element, mutation["Text"])

mutation_model = {
    "name": svg_h.set_to_property_text("Name"), 
    "land-effect": lambda element, card: svg_h.set_svg_element_text(element, card["Field"]),
    "text": set_mutation_text,
    "image": svg_h.set_svg_element_image,
}

creature_model = {
    "name": svg_h.set_to_property_text("Name"),
    "health":  svg_h.set_to_property_text("Health"),
    "catch-rate": svg_h.set_to_property_text("CatchRate"),
    "level": lambda element, card: svg_h.set_svg_element_text(element, "LVL " + str(card["Level"])),
    "image": svg_h.set_svg_element_image,
    "traits": lambda element, card: svg_h.set_svg_element_text(element,  substituteIconsInText("\n".join(card["Abilities"]))),
}

adaptation_model = {
    "card_name": svg_h.set_to_property_text("Name"), 
    "skill1-text": lambda element, card: parseAndApplySkillText(card["Skills"][0], element),
    "skill2-text": lambda element, card: parseAndApplySkillText(card["Skills"][1], element),
    "skill3-text": lambda element, card: parseAndApplySkillText(card["Skills"][2], element),
    "skill4-text": lambda element, card: parseAndApplySkillText(card["Skills"][3], element),
    "card_image": svg_h.set_svg_element_image,
}

card_model = {"creature": creature_model, "mutation": mutation_model, "adaptation": adaptation_model}

CC.full_card_creation("./data", card_model, "./", get_template_path_from_card, ["-grid"])
