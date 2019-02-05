#!/bin/bash

PRJDIR='/data/jangrawdc/PRJ18_HaskinsStory';

dataDir='/data/NIMH_Haskins/a182_v2' # data directory
scriptDir='/data/jangrawdc/PRJ18_HaskinsStory/Scripts'; # DJ script directory

subjects="h1002 h1003 h1004 h1005 h1007 h1010 h1011 "\
"h1012 h1013 h1014 h1016 h1018 h1022 h1024 h1027 "\
"h1028 h1029 h1031 h1034 h1035 h1036 h1038 h1040 "\
"h1043 h1046 h1048 h1050 h1054 h1057 h1058 h1059 "\
"h1061 h1068 h1073 h1074 h1076 h1082 h1083 h1087 "\
"h1088 h1093 h1095 h1096 h1097 h1098 h1102 h1106 "\
"h1108 h1113 h1118 h1120 h1129 h1142 h1146 h1150 "\
"h1152 h1153 h1154 h1157 h1161 h1163 h1167 h1168 "\
"h1169 h1174 h1175 h1176 h1179 h1180 h1184 h1185 "\
"h1186 h1187 h1189 h1197"
subjects=($subjects) # convert to array

# All subjects with complete fMRI Data
okSubj="h1002 h1003 h1004 h1005 h1007 h1010 h1011 "\
"h1012 h1013 h1014 h1016 h1018 h1022 h1024 h1027 "\
"h1028 h1029 h1031 h1034 h1035 h1036 h1038 h1040 "\
"h1043 h1046 h1048 h1050 h1054 h1057 h1058 h1059 "\
"h1061 h1068 h1073 h1074 h1076 h1082 h1083 h1087 "\
"h1088 h1093 h1095 h1096 h1097 h1098 h1102 h1106 "\
"h1108 h1113 h1118 h1120 h1129 h1142 h1146 h1150 "\
"h1152 h1153 h1154 h1157 h1161 h1163 h1167 h1168 "\
"h1169 h1174 h1175 h1176 h1179 h1180 h1184 h1185 "\
"h1186 h1187 h1189 h1197"
okSubj=($okSubj) #convert to array

# All subjects with complete fMRI and reading phenotyping data
okReadSubj="h1002 h1003 h1004 h1005 h1007 h1010 h1011 "\
"h1012 h1013 h1014 h1016 h1018 h1022 h1024 h1027 "\
"h1028 h1029 h1031 h1034 h1035 h1036 h1038 h1040 "\
"h1043 h1046 h1048 h1050 h1054 h1057 h1058 h1059 "\
"h1061 h1068 h1073 h1074 h1076 h1082 h1083 h1087 "\
"h1088 h1093 h1095 h1096 h1097 h1098 h1102 h1106 "\
"h1108 h1113 h1118 h1120 h1129 h1142 h1146 h1150 "\
"h1152 h1153 h1154 h1157 h1161 h1163 h1167 h1168 "\
"h1169 h1174 h1175 h1176 h1179 h1180 h1184 h1185 "\
"h1186 h1187 h1189 h1197"
okReadSubj=($okReadSubj) #convert to array

# top half readers
okReadSubj_top="TBD"
okReadSubj_top=($okReadSubj_top)
# bottom half readers
okReadSubj_bot="TBD"
okReadSubj_bot=($okReadSubj_bot)
