import os
import yaml
import shutil
import xml.etree.ElementTree as ET
import subprocess


def get_all_yaml_files_dir_and_subdirs(dir_path):
    yaml_files_dir_and_subdirs = []
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith(".yaml"):
                yaml_files_dir_and_subdirs.append(os.path.join(root, file))
    return yaml_files_dir_and_subdirs

def full_card_creation(data_parent_dir, card_model, destination_path, get_template_path_from_card, gen_options):
    cards_with_images = create_cards_from_yaml_files(data_parent_dir, card_model, destination_path, get_template_path_from_card)
    gen_options = set(gen_options)
    card_types = set()
    for card in cards_with_images:
        card_types.add(card[0]["CardType"])
    print(card_types)
    list_of_cards_by_type = []
    for card_type in card_types:
        list_of_cards_by_type.append(list(filter(lambda x: x[0]["CardType"] == card_type, cards_with_images)))
    if "-grid" in gen_options:
        create_grids(list_of_cards_by_type)
    if "-pdf" in gen_options:
        create_pdfs(list_of_cards_by_type)
    if "-paper" in gen_options:
        create_paper_prints(list_of_cards_by_type)
    
def create_grids(list_of_cards_by_type):
    check_if_folder_exists_and_create_if_not("./tts")
    for cards_of_type in list_of_cards_by_type:
        create_grid(list(map(lambda x: x[1], cards_of_type)), cards_of_type[0][0]["CardType"])

def create_pdfs(list_of_cards_by_type):
    check_if_folder_exists_and_create_if_not("./pdf")
    for cards_of_type in list_of_cards_by_type:
        create_pdf(list(map(lambda x: x[1], cards_of_type)), cards_of_type[0][0]["CardType"])

def create_paper_prints(list_of_cards_by_type):
    outputpath = "./paper-print/outputs/"
    check_if_folder_exists_and_create_if_not(outputpath)
    for cards_of_type in list_of_cards_by_type:
        create_paper_print(list(map(lambda x: x[1], cards_of_type)), cards_of_type[0][0]["CardType"], outputpath)
    pdf_option = "-sOutputFile=" + outputpath + "all_cards.pdf"
    paper_print_paths = list(map(lambda x: os.path.abspath(outputpath + x[0][0]["CardType"] + ".pdf"), list_of_cards_by_type))
    print(paper_print_paths)
    subprocess.check_output(['gs'] + ['-dBATCH'] + ['-dNOPAUSE'] + ['-q'] +['-sDEVICE=pdfwrite'] + [pdf_option] + paper_print_paths)

def create_pdf(images, name):
    subprocess.check_output(['convert']  + images + ['./pdf/all-' + name + '.pdf'])


def create_cards_from_yaml_files(data_parent_dir, card_model, destination_path, get_template_path_from_card):
    check_if_folder_exists_and_create_if_not(folder_path=destination_path+"/cards")
    yaml_files_dir_and_subdirs = get_all_yaml_files_dir_and_subdirs(data_parent_dir)
    card_data_and_image = []
    for yaml_file in yaml_files_dir_and_subdirs:
        card_data_and_image.extend(create_cards_from_yaml_file(yaml_file, card_model, destination_path, get_template_path_from_card))
    return card_data_and_image

def create_cards_from_yaml_file(yaml_file, card_model, destination_path, get_template_path_from_card):
    card_data_and_image = []
    with open(yaml_file, 'r') as stream:
        try:
            data = yaml.full_load(stream)
        except yaml.YAMLError as exc:
            print(exc)
        if data is not None:
            for card in data:
                card_data_and_image.append(create_card_data_and_image(card, card_model, destination_path, get_template_path_from_card))
    return card_data_and_image

def check_if_folder_exists_and_create_if_not(folder_path):
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

def create_card_data_and_image(card, card_model, destination_path, get_template_path_from_card):
    if "CardType" not in card:
        print(card["Name"])
        return None
    print(card["Name"] + " is being generated")
    destination_path_card_type = destination_path + "/cards/" + card["CardType"]
    check_if_folder_exists_and_create_if_not(destination_path_card_type) 

    filename = destination_path_card_type + "/" + card["Name"]
    filenamePNG = filename + ".png"
    filenameSVG = filename + ".svg"
    template_path = get_template_path_from_card(card)
    template_path = os.path.abspath(path=template_path)
    shutil.copyfile(template_path, filenameSVG)

    tree = ET.parse(filenameSVG)
    change_svg_to_data(tree, card, card_model)
    tree.write(filenameSVG)

    subprocess.check_output(['inkscape', filenameSVG, '-o', filenamePNG])
    if "AmountInDeck" in card:
        for i in range(2, card["AmountInDeck"] + 1):
            filenameCopy = filename + "_" + str(i) + ".png"
            subprocess.check_output(['cp', filenamePNG, filenameCopy])
    return (card, filenamePNG)

def change_svg_to_data(tree, card, card_model):
    root = tree.getroot()
    for element in root.iter():
        if "id" in element.attrib:
            for card_id in card_model[card["CardType"]].keys():
                if element.attrib["id"] == card_id:
                    card_model[card["CardType"]][card_id](element, card)

def create_grid(images, filename):
    for i in range(len(images) // 10 + 1):
        x = i * 10
        if len(images[x:x+10]) <= 0:
            continue
        subprocess.check_output(['convert'] + images[x:x+10]  + ['+append', './tts/grid-' + filename + str(i) + '.png'])
    subprocess.check_output(['touch'] + ['./tts/' + filename + '-full-grid.png'])
    subprocess.check_output(['rm'] + ['./tts/' + filename + '-full-grid.png'])
    subprocess.check_output(['convert', './tts/*' + filename + '*.png',  '-append', './tts/' + filename + '-full-grid.png'])
    for i in range(len(images) // 10 + 1):
        x = i * 10
        if len(images[x:x+10]) <= 0:
            continue
        subprocess.check_output(['rm'] + ['./tts/grid-' + filename + str(i) + '.png'])

def create_paper_print(images, file_name, outputpath):
    subprocess.check_output(['mkdir', '-p', outputpath])
    file_name = outputpath + file_name
    files = []
    for i in range(0,len(images),9):
        tree = ET.parse("./paper-print/paper-print-template.svg")
        root = tree.getroot()

        for element in root.iter():
            if "id" in element.attrib:
                if element.attrib["id"] == "card-1" and i < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i])
                elif element.attrib["id"] == "card-2" and i+1 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+1])
                elif element.attrib["id"] == "card-3" and i+2 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+2])
                elif element.attrib["id"] == "card-4" and i+3 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+3])
                elif element.attrib["id"] == "card-5" and i+4 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+4])
                elif element.attrib["id"] == "card-6" and i+5 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+5])
                elif element.attrib["id"] == "card-7" and i+6 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+6])
                elif element.attrib["id"] == "card-8" and i+7 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+7])
                elif element.attrib["id"] == "card-9" and i+8 < len(images):
                    element.attrib["{http://www.w3.org/1999/xlink}href"] = os.path.abspath(images[i+8])

        filename_tmp = file_name + str(i//9)
        file_name_tmp_svg = filename_tmp + ".svg"
        file_name_tmp_pdf = filename_tmp + ".pdf"
        tree.write(file_name_tmp_svg)
        subprocess.check_output(['inkscape', file_name_tmp_svg, '-o', file_name_tmp_pdf])
        subprocess.check_output(['rm', file_name_tmp_svg])
        files.append(file_name_tmp_pdf)
    pdf_option = "-sOutputFile=" + file_name + ".pdf"
    subprocess.check_output(['gs'] + ['-dBATCH'] + ['-dNOPAUSE'] + ['-q'] +['-sDEVICE=pdfwrite'] + [pdf_option] + files)
    subprocess.check_output(['rm']  + files)
