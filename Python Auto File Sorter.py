import os , shutil

path = r"D:\Downloads/"
file_names = os.listdir(path)

folder_names = ['csvs', 'images', 'txts', 'other']
for i in range (0,len(folder_names)):
    if not os.path.exists(path + folder_names[i]):
        print(path + folder_names[i])
        os.makedirs(path + folder_names[i])

folder_names = ['csvs', 'images', 'txts', 'other']
for i in range (0,len(folder_names)):
    if not os.path.exists(path + folder_names[i]):
        os.makedirs(path + folder_names[i])
for file in file_names:
    if (".csv" in file or ".xlsx" in file ) and not os.path.exists(path + "csvs/" + file):
        shutil.move(path + file, path + "csvs/" + file )
    elif (".png" in file or ".JPG" in file or ".jpeg" in file ) and not os.path.exists(path + "images/" + file):
        shutil.move(path + file, path + "images/" + file )
    elif ".txt" in file  and not os.path.exists(path + "txts/" + file):
        shutil.move(path + file, path + "txts/" + file )
    else:
        shutil.move(path + file, path + "other/" + file )
    