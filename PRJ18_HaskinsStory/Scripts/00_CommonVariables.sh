#!/bin/bash

# Updated 3/4/19 by DJ - updated okReadSubj_top and _bot
# Updated 7/11/19 by DJ - added okReadSubj_iqMatched

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

# All subjects with complete fMRI Data and ok motion (<15% censored)
okSubj="h1002 h1003 h1004 h1010 h1011 "\
"h1012 h1013 h1014 h1016 h1018 h1022 h1024 h1027 "\
"h1028 h1029 h1031 h1034 h1035 h1036 h1038 "\
"h1043 h1046 h1048 h1054 h1057 h1058 h1059 "\
"h1061 h1073 h1074 h1076 h1082 h1083 h1087 "\
"h1088 h1093 h1095 h1096 h1097 h1098 h1102 h1106 "\
"h1108 h1118 h1120 h1129 h1142 h1146 h1150 "\
"h1152 h1153 h1154 h1157 h1161 h1163 h1167 h1168 "\
"h1169 h1174 h1175 h1176 h1179 h1180 h1184 h1185 "\
"h1186 h1187 h1189 h1197"
okSubj=($okSubj) #convert to array

# All subjects with complete fMRI and reading phenotyping data
okReadSubj="h1002 h1003 h1004 h1010 h1011 "\
"h1012 h1013 h1014 h1016 h1018 h1022 h1024 h1027 "\
"h1028 h1029 h1031 h1034 h1035 h1036 h1038 "\
"h1043 h1046 h1048 h1054 h1057 h1058 h1059 "\
"h1061 h1073 h1074 h1076 h1082 h1083 h1087 "\
"h1088 h1093 h1095 h1096 h1097 h1098 h1102 h1106 "\
"h1108 h1118 h1120 h1129 h1142 h1146 h1150 "\
"h1152 h1153 h1154 h1157 h1161 h1163 h1167 h1168 "\
"h1169 h1174 h1175 h1176 h1179 h1180 h1184 h1185 "\
"h1186 h1187 h1189 h1197"
okReadSubj=($okReadSubj) #convert to array

# top half readers
okReadSubj_top="h1157 h1028 h1073 h1036 h1093 h1118 "\
"h1031 h1169 h1016 h1074 h1002 h1102 h1152 h1167 "\
"h1185 h1027 h1043 h1146 h1179 h1018 h1098 h1012 "\
"h1186 h1010 h1189 h1082 h1061 h1175 h1014 h1011 "\
"h1076 h1013 h1048 h1022"
okReadSubj_top=($okReadSubj_top) # convert to array

# bottom half readers
okReadSubj_bot="h1029 h1097 h1108 h1046 h1038 h1034 "\
"h1187 h1024 h1003 h1083 h1120 h1180 h1161 h1174 "\
"h1129 h1088 h1035 h1096 h1176 h1150 h1197 h1163 "\
"h1058 h1142 h1106 h1184 h1095 h1153 h1168 h1059 "\
"h1004 h1057 h1087 h1054 h1154"
okReadSubj_bot=($okReadSubj_bot) # convert to array


# set of 40 subjects in which groups are matched for IQ
okReadSubj_iqMatched="h1013 h1012 h1167 h1031 h1043 "\
"h1146 h1098 h1018 h1169 h1014 h1197 h1083 h1129 "\
"h1142 h1187 h1046 h1088 h1029 h1161 h1108 h1179 "\
"h1175 h1186 h1152 h1102 h1082 h1189 h1010 h1011 "\
"h1076 h1176 h1058 h1180 h1038 h1024 h1120 h1003 "\
"h1168 h1034 h1004"
okReadSubj_iqMatched=($okReadSubj_iqMatched) # convert to array
