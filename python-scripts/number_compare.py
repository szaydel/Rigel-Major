#!/usr/bin/python3.1
#
#
#
def sams(msg,msg_2,default):
    while True:
        try:
            value_1 = input(msg)
            value_2 = input(msg_2)
            if not value_1 or value_2 and default is not int(default):
                return 'Something is missing.'
            i = int(value_1)
            j = int(value_2)
            if i < 1 or j < 1:
                print("Number should be greater than 0", 'Entered: ', i, j)
            else:
                if i > j:
                    return print(i, 'is larger than', j)
                else:
                    return print(j, 'is larger than', i)
        except ValueError as err:
            print(err)