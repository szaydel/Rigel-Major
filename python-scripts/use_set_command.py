#!/bin/python3.1
##
##
desired_animal = raw_input()
allowed_animals = set(("dog", "cat", "small bird"))
if desired_animal in allowed_animals:
    print("You can have this animal in your house\n")
else:
    print("I'm afraid you can't have this animal in your house.\n")