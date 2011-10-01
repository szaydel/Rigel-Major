#!/usr/bin/env python

## Create a class used to split strings at every comma ','
## and combine two strings in the class instance into a tuple
class SplitOnComma:
    char = ','
    def __init__(self,x,y):
        self.x = x
        self.y = y
    def make_tuple(self):
        ''' Here are two ways of doing the same
        exact thig. Difference in second choice
        is a non-hard-coded approach, which is
        more elegant
        res_a = self.x.split(SplitOnComma.char)
        res_b = self.y.split(SplitOnComma.char)
        '''
        res_a = self.x.split(self.__class__.char)
        res_b = self.y.split(self.__class__.char)
        return (res_a,res_b)
        
class LessOrMore:
    def __init__ (self,value,x=10,y=100):
        self.lowmark = x
        self.highmark = y
        self.value = value
    def compare(self):
        if self.lowmark < self.value < self.highmark :
            print('Value %s is greater than %s \
but lower than %s' % (self.value, self.lowmark,self.highmark))
        elif self.lowmark > self.value:
            print('Value %s is lower than %s \
and lower than %s' % (self.value, self.lowmark,self.highmark))
        elif self.value > self.highmark:
            print('Value %s is greater than %s \
and greater than %s' % (self.value, self.lowmark,self.highmark))
            


class SiMatch:
    '''
    Take in a string, and pattern, and return a match, if there is a match
    '''
    def __init__(self, string, pattern='[a-z]'):
        self.pattern = pattern
        self.string = string
        
    def match(self):
        a = re.compile(self.pattern,re.IGNORECASE)
        b = a.findall(self.string)
        if b:
            count_of_matches = len(b)
            if count_of_matches > 1: m = 'es'
            else: m = ''
            print('Found %s match%s for %s' % (len(b), m, self.pattern))
            return b
        else:
            print('Did not find any matches for %s' % (self.pattern))
            return None