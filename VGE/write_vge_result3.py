#/*
# *    Virtual Grid Engine
# *
# *   (c) Copyright 2017-2019 Satoshi ITO, Masaaki Yadome, and Satoru MIYANO
# */


def write_vge_result3(joblist, filename):
    #
    # joblist : dict of dict
    #
    lines = ""
    lines += "command_id,command\n"

    #
    # make list to be printed
    #
    for id, value in joblist.items():
        temp = "%i, \"%s\"" % (id, value["command"])
        temp2 = temp.replace("\n", "\\n")
        temp2 += "\n"
        lines += temp2
        del temp
        del temp2

    #
    # write file
    #
    try:
        with open(filename, 'w') as writefile:
            writefile.write(lines)

    except Exception as error:
        print("error was occured. check [%s]." % error)

    return
