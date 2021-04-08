// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:2,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.1280277,fgcg:0.1953466,fgcb:0.2352941,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2183,x:41345,y:34354,varname:node_2183,prsc:2|custl-6793-OUT;n:type:ShaderForge.SFN_FragmentPosition,id:8628,x:33592,y:31919,varname:node_8628,prsc:2;n:type:ShaderForge.SFN_Normalize,id:8505,x:33765,y:31919,varname:node_8505,prsc:2|IN-8628-XYZ;n:type:ShaderForge.SFN_ComponentMask,id:1819,x:32562,y:34353,varname:node_1819,prsc:2,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-7764-OUT;n:type:ShaderForge.SFN_Subtract,id:9474,x:33000,y:34190,varname:node_9474,prsc:2|A-6516-OUT,B-951-OUT;n:type:ShaderForge.SFN_Add,id:4283,x:33002,y:34603,varname:node_4283,prsc:2|A-5407-OUT,B-1819-OUT;n:type:ShaderForge.SFN_Min,id:9894,x:33238,y:34603,varname:node_9894,prsc:2|A-5407-OUT,B-4283-OUT;n:type:ShaderForge.SFN_Vector1,id:6516,x:32772,y:34054,varname:node_6516,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:5407,x:32795,y:34473,varname:node_5407,prsc:2,v1:1;n:type:ShaderForge.SFN_Min,id:8052,x:33221,y:34190,varname:node_8052,prsc:2|A-6516-OUT,B-9474-OUT;n:type:ShaderForge.SFN_Power,id:8959,x:33675,y:34179,varname:node_8959,prsc:2|VAL-4072-OUT,EXP-5886-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4841,x:33293,y:34361,ptovrint:False,ptlb:HorizonSharpnessSky,ptin:_HorizonSharpnessSky,varname:node_4841,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:5;n:type:ShaderForge.SFN_Power,id:3666,x:33538,y:34596,varname:node_3666,prsc:2|VAL-9894-OUT,EXP-7457-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1472,x:33112,y:34795,ptovrint:False,ptlb:HorizonSharpnessGround,ptin:_HorizonSharpnessGround,varname:node_1472,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_OneMinus,id:3209,x:33881,y:34179,varname:node_3209,prsc:2|IN-8959-OUT;n:type:ShaderForge.SFN_OneMinus,id:6157,x:33729,y:34596,varname:node_6157,prsc:2|IN-3666-OUT;n:type:ShaderForge.SFN_OneMinus,id:8705,x:36061,y:34366,varname:node_8705,prsc:2|IN-6233-OUT;n:type:ShaderForge.SFN_Subtract,id:9163,x:36251,y:34366,varname:node_9163,prsc:2|A-8705-OUT,B-2490-OUT;n:type:ShaderForge.SFN_Multiply,id:5451,x:36525,y:34358,varname:node_5451,prsc:2|A-5106-RGB,B-9163-OUT;n:type:ShaderForge.SFN_Color,id:5106,x:36098,y:34675,ptovrint:False,ptlb:HorizonColor,ptin:_HorizonColor,varname:node_5106,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.8666667,c2:0.8666667,c3:0.8666667,c4:1;n:type:ShaderForge.SFN_Color,id:317,x:36152,y:34006,ptovrint:False,ptlb:SkyColor,ptin:_SkyColor,varname:node_317,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.3529412,c2:0.6470588,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:9390,x:36525,y:34160,varname:node_9390,prsc:2|A-317-RGB,B-9532-OUT,C-7163-OUT,D-3297-OUT;n:type:ShaderForge.SFN_Add,id:6166,x:36728,y:34244,varname:node_6166,prsc:2|A-9390-OUT,B-5451-OUT;n:type:ShaderForge.SFN_Add,id:5212,x:36937,y:34244,varname:node_5212,prsc:2|A-6166-OUT,B-5601-OUT;n:type:ShaderForge.SFN_Color,id:6998,x:36458,y:34737,ptovrint:False,ptlb:GroundColor,ptin:_GroundColor,varname:node_6998,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.282353,c2:0.282353,c3:0.282353,c4:1;n:type:ShaderForge.SFN_Multiply,id:5601,x:36729,y:34575,varname:node_5601,prsc:2|A-6998-RGB,B-2490-OUT;n:type:ShaderForge.SFN_Multiply,id:5492,x:37604,y:34229,varname:node_5492,prsc:2|A-188-OUT,B-2630-OUT;n:type:ShaderForge.SFN_ViewVector,id:4641,x:35059,y:31548,varname:node_4641,prsc:2;n:type:ShaderForge.SFN_LightVector,id:8856,x:35059,y:31763,varname:node_8856,prsc:2;n:type:ShaderForge.SFN_LightColor,id:4809,x:36331,y:31825,varname:node_4809,prsc:2;n:type:ShaderForge.SFN_Normalize,id:795,x:35258,y:31548,varname:node_795,prsc:2|IN-4641-OUT;n:type:ShaderForge.SFN_Negate,id:2445,x:35258,y:31763,varname:node_2445,prsc:2|IN-8856-OUT;n:type:ShaderForge.SFN_Dot,id:5365,x:35443,y:31649,varname:node_5365,prsc:2,dt:0|A-795-OUT,B-2445-OUT;n:type:ShaderForge.SFN_Clamp01,id:1984,x:35630,y:31649,varname:node_1984,prsc:2|IN-5365-OUT;n:type:ShaderForge.SFN_Multiply,id:2659,x:35496,y:32028,varname:node_2659,prsc:2|A-7106-OUT,B-7106-OUT;n:type:ShaderForge.SFN_Multiply,id:2867,x:35496,y:32176,varname:node_2867,prsc:2|A-1286-OUT,B-1286-OUT;n:type:ShaderForge.SFN_OneMinus,id:8355,x:35674,y:32028,varname:node_8355,prsc:2|IN-2659-OUT;n:type:ShaderForge.SFN_OneMinus,id:3772,x:35674,y:32176,varname:node_3772,prsc:2|IN-2867-OUT;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:5695,x:36071,y:32076,varname:node_5695,prsc:2|IN-1984-OUT,IMIN-8355-OUT,IMAX-3772-OUT,OMIN-4463-OUT,OMAX-4479-OUT;n:type:ShaderForge.SFN_Vector1,id:4463,x:35848,y:32292,varname:node_4463,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:4479,x:35848,y:32343,varname:node_4479,prsc:2,v1:0;n:type:ShaderForge.SFN_Clamp01,id:2049,x:36250,y:32076,varname:node_2049,prsc:2|IN-5695-OUT;n:type:ShaderForge.SFN_Multiply,id:3736,x:36931,y:31949,varname:node_3736,prsc:2|A-4809-RGB,B-1019-OUT;n:type:ShaderForge.SFN_Multiply,id:8918,x:37342,y:31942,varname:node_8918,prsc:2|A-3736-OUT,B-6963-OUT;n:type:ShaderForge.SFN_Add,id:387,x:38689,y:34484,varname:node_387,prsc:2|A-7531-OUT,B-5754-OUT;n:type:ShaderForge.SFN_Color,id:5202,x:35373,y:33428,ptovrint:False,ptlb:AmbientColorSunSide,ptin:_AmbientColorSunSide,varname:node_5202,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.827451,c3:0.4156863,c4:1;n:type:ShaderForge.SFN_LightVector,id:455,x:33008,y:33494,varname:node_455,prsc:2;n:type:ShaderForge.SFN_ComponentMask,id:3592,x:33367,y:33494,varname:node_3592,prsc:2,cc1:0,cc2:2,cc3:-1,cc4:-1|IN-6839-OUT;n:type:ShaderForge.SFN_ViewVector,id:5159,x:33185,y:33326,varname:node_5159,prsc:2;n:type:ShaderForge.SFN_ComponentMask,id:4237,x:33356,y:33326,varname:node_4237,prsc:2,cc1:0,cc2:2,cc3:-1,cc4:-1|IN-5159-OUT;n:type:ShaderForge.SFN_Normalize,id:6931,x:33537,y:33326,varname:node_6931,prsc:2|IN-4237-OUT;n:type:ShaderForge.SFN_Dot,id:9252,x:33717,y:33366,varname:node_9252,prsc:2,dt:0|A-6931-OUT,B-5438-OUT;n:type:ShaderForge.SFN_Clamp01,id:4423,x:33897,y:33366,varname:node_4423,prsc:2|IN-9252-OUT;n:type:ShaderForge.SFN_Multiply,id:7822,x:36137,y:33623,varname:node_7822,prsc:2|A-5202-RGB,B-9928-OUT;n:type:ShaderForge.SFN_Add,id:7927,x:37170,y:34103,varname:node_7927,prsc:2|A-7822-OUT,B-5212-OUT;n:type:ShaderForge.SFN_Color,id:1707,x:35407,y:33231,ptovrint:False,ptlb:AmbientColorSunOpposite,ptin:_AmbientColorSunOpposite,varname:node_1707,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.827451,c3:0.4156863,c4:1;n:type:ShaderForge.SFN_Multiply,id:6099,x:36120,y:33371,varname:node_6099,prsc:2|A-1707-RGB,B-8058-OUT;n:type:ShaderForge.SFN_Add,id:188,x:37361,y:34049,varname:node_188,prsc:2|A-6099-OUT,B-7927-OUT;n:type:ShaderForge.SFN_Power,id:4080,x:33675,y:34022,varname:node_4080,prsc:2|VAL-4072-OUT,EXP-2259-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2088,x:33264,y:34039,ptovrint:False,ptlb:AmbientColorSharpness,ptin:_AmbientColorSharpness,varname:node_2088,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:10;n:type:ShaderForge.SFN_OneMinus,id:7163,x:35859,y:34087,varname:node_7163,prsc:2|IN-6704-OUT;n:type:ShaderForge.SFN_Negate,id:6839,x:33199,y:33494,varname:node_6839,prsc:2|IN-455-OUT;n:type:ShaderForge.SFN_Normalize,id:5438,x:33537,y:33494,varname:node_5438,prsc:2|IN-3592-OUT;n:type:ShaderForge.SFN_Set,id:2105,x:37631,y:31951,varname:Sun,prsc:2|IN-8918-OUT;n:type:ShaderForge.SFN_Get,id:7531,x:38440,y:34433,varname:node_7531,prsc:2|IN-2105-OUT;n:type:ShaderForge.SFN_Set,id:4457,x:37858,y:34230,varname:Gradient,prsc:2|IN-5492-OUT;n:type:ShaderForge.SFN_Get,id:5754,x:38451,y:34520,varname:node_5754,prsc:2|IN-4457-OUT;n:type:ShaderForge.SFN_Set,id:49,x:33933,y:31919,varname:NWorldPos,prsc:2|IN-8505-OUT;n:type:ShaderForge.SFN_Get,id:7764,x:32353,y:34371,varname:node_7764,prsc:2|IN-49-OUT;n:type:ShaderForge.SFN_Set,id:4098,x:34487,y:34177,varname:SkyMask,prsc:2|IN-3209-OUT;n:type:ShaderForge.SFN_Get,id:9532,x:36285,y:34140,varname:node_9532,prsc:2|IN-4098-OUT;n:type:ShaderForge.SFN_Get,id:6233,x:35859,y:34366,varname:node_6233,prsc:2|IN-4098-OUT;n:type:ShaderForge.SFN_Set,id:7123,x:34472,y:34574,varname:GroundMask,prsc:2|IN-6157-OUT;n:type:ShaderForge.SFN_Get,id:2490,x:36056,y:34501,varname:node_2490,prsc:2|IN-7123-OUT;n:type:ShaderForge.SFN_Set,id:2626,x:34512,y:33606,varname:SunSideMask,prsc:2|IN-7977-OUT;n:type:ShaderForge.SFN_Get,id:9928,x:35884,y:33670,varname:node_9928,prsc:2|IN-2626-OUT;n:type:ShaderForge.SFN_Multiply,id:1019,x:36691,y:32164,varname:node_1019,prsc:2|A-2049-OUT,B-4716-OUT;n:type:ShaderForge.SFN_Get,id:4716,x:36448,y:32376,varname:node_4716,prsc:2|IN-4098-OUT;n:type:ShaderForge.SFN_Add,id:951,x:32729,y:34181,varname:node_951,prsc:2|A-2619-OUT,B-1819-OUT;n:type:ShaderForge.SFN_Negate,id:2619,x:32547,y:34030,varname:node_2619,prsc:2|IN-6621-OUT;n:type:ShaderForge.SFN_Clamp01,id:4072,x:33408,y:34190,varname:node_4072,prsc:2|IN-8052-OUT;n:type:ShaderForge.SFN_Get,id:6704,x:35552,y:34090,varname:node_6704,prsc:2|IN-2626-OUT;n:type:ShaderForge.SFN_Multiply,id:7977,x:34291,y:33606,varname:node_7977,prsc:2|A-3896-OUT,B-3209-OUT,C-4080-OUT;n:type:ShaderForge.SFN_Set,id:7676,x:34524,y:33365,varname:SunSideMaskOpposite,prsc:2|IN-1324-OUT;n:type:ShaderForge.SFN_Multiply,id:1324,x:34291,y:33365,varname:node_1324,prsc:2|A-8677-OUT,B-4080-OUT,C-3209-OUT;n:type:ShaderForge.SFN_Get,id:8058,x:35885,y:33264,varname:node_8058,prsc:2|IN-7676-OUT;n:type:ShaderForge.SFN_ComponentMask,id:6888,x:33367,y:33640,varname:node_6888,prsc:2,cc1:0,cc2:2,cc3:-1,cc4:-1|IN-455-OUT;n:type:ShaderForge.SFN_Normalize,id:5388,x:33537,y:33640,varname:node_5388,prsc:2|IN-6888-OUT;n:type:ShaderForge.SFN_Dot,id:2735,x:33717,y:33585,varname:node_2735,prsc:2,dt:0|A-6931-OUT,B-5388-OUT;n:type:ShaderForge.SFN_Clamp01,id:6647,x:33897,y:33569,varname:node_6647,prsc:2|IN-2735-OUT;n:type:ShaderForge.SFN_OneMinus,id:3297,x:35859,y:34211,varname:node_3297,prsc:2|IN-2930-OUT;n:type:ShaderForge.SFN_Get,id:2930,x:35552,y:34207,varname:node_2930,prsc:2|IN-7676-OUT;n:type:ShaderForge.SFN_Get,id:648,x:35451,y:36055,varname:node_648,prsc:2|IN-49-OUT;n:type:ShaderForge.SFN_ComponentMask,id:3809,x:35655,y:36055,varname:node_3809,prsc:2,cc1:0,cc2:1,cc3:2,cc4:-1|IN-648-OUT;n:type:ShaderForge.SFN_Append,id:2744,x:35853,y:35995,varname:node_2744,prsc:2|A-3809-R,B-3809-B;n:type:ShaderForge.SFN_Abs,id:129,x:35853,y:36132,varname:node_129,prsc:2|IN-3809-G;n:type:ShaderForge.SFN_Divide,id:1829,x:36289,y:35997,varname:node_1829,prsc:2|A-2744-OUT,B-9519-OUT;n:type:ShaderForge.SFN_Tex2d,id:8818,x:36937,y:35984,ptovrint:False,ptlb:CloudsTexture,ptin:_CloudsTexture,varname:node_8818,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:True,tagnrm:False,ntxv:2,isnm:False|UVIN-1782-OUT;n:type:ShaderForge.SFN_Set,id:4522,x:38601,y:35724,varname:Clouds,prsc:2|IN-593-OUT;n:type:ShaderForge.SFN_Get,id:6666,x:38800,y:34584,varname:node_6666,prsc:2|IN-4522-OUT;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:9519,x:36106,y:36132,varname:node_9519,prsc:2|IN-129-OUT,IMIN-6897-OUT,IMAX-2864-OUT,OMIN-7798-OUT,OMAX-2864-OUT;n:type:ShaderForge.SFN_Vector1,id:6897,x:35853,y:36261,varname:node_6897,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:2864,x:35853,y:36319,varname:node_2864,prsc:2,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:2701,x:35631,y:36406,ptovrint:False,ptlb:CloudsFarTiling,ptin:_CloudsFarTiling,varname:node_2701,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Set,id:544,x:38621,y:36136,varname:CloudMask,prsc:2|IN-966-OUT;n:type:ShaderForge.SFN_Multiply,id:2328,x:36497,y:36000,varname:node_2328,prsc:2|A-1829-OUT,B-8014-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8014,x:36289,y:36166,ptovrint:False,ptlb:CloudsTiling,ptin:_CloudsTiling,varname:node_8014,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:1782,x:36707,y:36000,varname:node_1782,prsc:2|A-2328-OUT,B-6236-OUT;n:type:ShaderForge.SFN_Vector4Property,id:8968,x:36289,y:36267,ptovrint:False,ptlb:CloudsOffset,ptin:_CloudsOffset,varname:node_8968,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0,v2:0,v3:0,v4:0;n:type:ShaderForge.SFN_Append,id:6236,x:36508,y:36166,varname:node_6236,prsc:2|A-8968-X,B-8968-Y;n:type:ShaderForge.SFN_Add,id:8756,x:35853,y:36522,varname:node_8756,prsc:2|A-3809-G,B-6615-OUT;n:type:ShaderForge.SFN_Clamp01,id:9322,x:36026,y:36508,varname:node_9322,prsc:2|IN-8756-OUT;n:type:ShaderForge.SFN_Power,id:3453,x:36233,y:36474,varname:node_3453,prsc:2|VAL-9322-OUT,EXP-3153-OUT;n:type:ShaderForge.SFN_Multiply,id:2388,x:37637,y:36071,varname:node_2388,prsc:2|A-8818-A,B-3453-OUT;n:type:ShaderForge.SFN_Multiply,id:966,x:37848,y:36081,varname:node_966,prsc:2|A-2388-OUT,B-5981-OUT;n:type:ShaderForge.SFN_Add,id:6567,x:37698,y:35900,varname:node_6567,prsc:2|A-4171-OUT,B-7652-OUT;n:type:ShaderForge.SFN_Subtract,id:7652,x:37052,y:35779,varname:node_7652,prsc:2|A-9403-OUT,B-8017-OUT;n:type:ShaderForge.SFN_Slider,id:9403,x:36676,y:35758,ptovrint:False,ptlb:CloudsBrightness,ptin:_CloudsBrightness,varname:node_9403,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Vector1,id:8017,x:36833,y:35823,varname:node_8017,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:593,x:38420,y:35702,varname:node_593,prsc:2|A-6567-OUT,B-1202-OUT;n:type:ShaderForge.SFN_LightColor,id:3925,x:37891,y:35742,varname:node_3925,prsc:2;n:type:ShaderForge.SFN_Blend,id:1160,x:38986,y:34541,varname:node_1160,prsc:2,blmd:10,clmp:True|SRC-387-OUT,DST-6666-OUT;n:type:ShaderForge.SFN_Lerp,id:3472,x:39192,y:34505,varname:node_3472,prsc:2|A-387-OUT,B-1160-OUT,T-8943-OUT;n:type:ShaderForge.SFN_Get,id:8943,x:39181,y:34644,varname:node_8943,prsc:2|IN-544-OUT;n:type:ShaderForge.SFN_Blend,id:1202,x:38219,y:35867,varname:node_1202,prsc:2,blmd:10,clmp:True|SRC-3925-RGB,DST-2-RGB;n:type:ShaderForge.SFN_Color,id:2,x:38008,y:35943,ptovrint:False,ptlb:CloudsColor,ptin:_CloudsColor,varname:node_2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Set,id:5894,x:40837,y:34554,varname:BeforeDithering,prsc:2|IN-7592-OUT;n:type:ShaderForge.SFN_Get,id:6793,x:41118,y:34580,varname:node_6793,prsc:2|IN-5894-OUT;n:type:ShaderForge.SFN_Get,id:8667,x:35096,y:38201,varname:node_8667,prsc:2|IN-49-OUT;n:type:ShaderForge.SFN_ComponentMask,id:8144,x:35310,y:38201,varname:node_8144,prsc:2,cc1:0,cc2:1,cc3:2,cc4:-1|IN-8667-OUT;n:type:ShaderForge.SFN_Pi,id:9997,x:35327,y:38363,varname:node_9997,prsc:2;n:type:ShaderForge.SFN_ArcTan2,id:5025,x:35600,y:37856,varname:node_5025,prsc:2,attp:0|A-8144-R,B-8144-B;n:type:ShaderForge.SFN_Tau,id:2966,x:35600,y:38011,varname:node_2966,prsc:2;n:type:ShaderForge.SFN_Divide,id:3568,x:35799,y:37932,varname:node_3568,prsc:2|A-5025-OUT,B-2966-OUT;n:type:ShaderForge.SFN_ArcSin,id:5590,x:35600,y:38252,varname:node_5590,prsc:2|IN-8144-G;n:type:ShaderForge.SFN_Divide,id:2401,x:35589,y:38378,varname:node_2401,prsc:2|A-9997-OUT,B-7722-OUT;n:type:ShaderForge.SFN_Vector1,id:7722,x:35310,y:38485,varname:node_7722,prsc:2,v1:2;n:type:ShaderForge.SFN_Divide,id:3874,x:35817,y:38329,varname:node_3874,prsc:2|A-5590-OUT,B-2401-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7230,x:35542,y:38618,ptovrint:False,ptlb:PixMapOffset,ptin:_PixMapOffset,varname:node_7230,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:4271,x:36033,y:38319,varname:node_4271,prsc:2|A-3874-OUT,B-3782-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9134,x:36142,y:38449,ptovrint:False,ptlb:PixMapTilingV,ptin:_PixMapTilingV,varname:node_9134,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:2806,x:36306,y:38316,varname:node_2806,prsc:2|A-4271-OUT,B-9134-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9528,x:36001,y:38103,ptovrint:False,ptlb:PixMapTilingU,ptin:_PixMapTilingU,varname:node_9528,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:6549,x:36228,y:37969,varname:node_6549,prsc:2|A-3568-OUT,B-9528-OUT;n:type:ShaderForge.SFN_Append,id:9079,x:36550,y:38129,varname:node_9079,prsc:2|A-6549-OUT,B-2806-OUT;n:type:ShaderForge.SFN_Tex2d,id:7339,x:36861,y:38083,ptovrint:False,ptlb:PixMap,ptin:_PixMap,varname:node_7339,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:True,tagnrm:False,ntxv:2,isnm:False|UVIN-9079-OUT;n:type:ShaderForge.SFN_Set,id:9914,x:37628,y:37885,varname:PixMap,prsc:2|IN-5124-OUT;n:type:ShaderForge.SFN_Set,id:8388,x:37628,y:38109,varname:PixMapMask,prsc:2|IN-7339-A;n:type:ShaderForge.SFN_Add,id:7592,x:40616,y:34554,varname:node_7592,prsc:2|A-8125-OUT,B-2484-OUT;n:type:ShaderForge.SFN_Multiply,id:8125,x:40419,y:34536,varname:node_8125,prsc:2|A-9115-OUT,B-6517-OUT;n:type:ShaderForge.SFN_OneMinus,id:6517,x:40219,y:34690,varname:node_6517,prsc:2|IN-2409-OUT;n:type:ShaderForge.SFN_Get,id:2409,x:40020,y:34748,varname:node_2409,prsc:2|IN-8388-OUT;n:type:ShaderForge.SFN_Get,id:207,x:40020,y:34864,varname:node_207,prsc:2|IN-9914-OUT;n:type:ShaderForge.SFN_Multiply,id:2484,x:40389,y:34797,varname:node_2484,prsc:2|A-2409-OUT,B-207-OUT;n:type:ShaderForge.SFN_Negate,id:3782,x:35817,y:38525,varname:node_3782,prsc:2|IN-7230-OUT;n:type:ShaderForge.SFN_Slider,id:7064,x:35249,y:36517,ptovrint:False,ptlb:CloudsCutoff,ptin:_CloudsCutoff,varname:node_7064,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Negate,id:6615,x:35651,y:36502,varname:node_6615,prsc:2|IN-7064-OUT;n:type:ShaderForge.SFN_Slider,id:5981,x:37512,y:36231,ptovrint:False,ptlb:CloudsOpacity,ptin:_CloudsOpacity,varname:node_5981,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:3153,x:35882,y:36678,ptovrint:False,ptlb:CloudsFalloff,ptin:_CloudsFalloff,varname:node_3153,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0.001,cur:0.001,max:10;n:type:ShaderForge.SFN_Abs,id:7798,x:35853,y:36376,varname:node_7798,prsc:2|IN-2701-OUT;n:type:ShaderForge.SFN_Slider,id:6621,x:32212,y:34030,ptovrint:False,ptlb:HorizonOffset,ptin:_HorizonOffset,varname:node_6621,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:2630,x:37233,y:34355,ptovrint:False,ptlb:SkyIntensity,ptin:_SkyIntensity,varname:node_2630,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:1796,x:34762,y:32060,ptovrint:False,ptlb:SunRadius,ptin:_SunRadius,varname:node_1796,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.05,max:1;n:type:ShaderForge.SFN_Slider,id:6572,x:34762,y:32184,ptovrint:False,ptlb:SunFalloff,ptin:_SunFalloff,varname:node_6572,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0.001,cur:0.02,max:1;n:type:ShaderForge.SFN_Add,id:2217,x:35165,y:32157,varname:node_2217,prsc:2|A-1796-OUT,B-6572-OUT;n:type:ShaderForge.SFN_Relay,id:7106,x:35361,y:32038,varname:node_7106,prsc:2|IN-1796-OUT;n:type:ShaderForge.SFN_Relay,id:1286,x:35361,y:32186,varname:node_1286,prsc:2|IN-2217-OUT;n:type:ShaderForge.SFN_Slider,id:6963,x:36886,y:32184,ptovrint:False,ptlb:SunIntensity,ptin:_SunIntensity,varname:node_6963,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_OneMinus,id:8677,x:34088,y:33365,varname:node_8677,prsc:2|IN-4423-OUT;n:type:ShaderForge.SFN_OneMinus,id:3896,x:34101,y:33580,varname:node_3896,prsc:2|IN-6647-OUT;n:type:ShaderForge.SFN_Abs,id:2259,x:33489,y:34022,varname:node_2259,prsc:2|IN-2088-OUT;n:type:ShaderForge.SFN_Abs,id:5886,x:33475,y:34332,varname:node_5886,prsc:2|IN-4841-OUT;n:type:ShaderForge.SFN_Abs,id:7457,x:33326,y:34751,varname:node_7457,prsc:2|IN-1472-OUT;n:type:ShaderForge.SFN_Color,id:7777,x:36861,y:37888,ptovrint:False,ptlb:PixMapColor,ptin:_PixMapColor,varname:node_7777,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:9176,x:37056,y:37941,varname:node_9176,prsc:2|A-7777-RGB,B-7339-RGB;n:type:ShaderForge.SFN_Slider,id:3616,x:36347,y:37469,ptovrint:False,ptlb:FogIntensityOnSkybox,ptin:_FogIntensityOnSkybox,varname:node_3616,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1,max:1;n:type:ShaderForge.SFN_FogColor,id:2168,x:36490,y:37317,varname:node_2168,prsc:2;n:type:ShaderForge.SFN_Lerp,id:5455,x:37234,y:37885,varname:node_5455,prsc:2|A-9176-OUT,B-5569-OUT,T-6410-OUT;n:type:ShaderForge.SFN_Set,id:4233,x:36683,y:37326,varname:FogColor,prsc:2|IN-2168-RGB;n:type:ShaderForge.SFN_Set,id:9491,x:36676,y:37444,varname:FogIntensity,prsc:2|IN-3616-OUT;n:type:ShaderForge.SFN_Get,id:5569,x:37035,y:37720,varname:node_5569,prsc:2|IN-4233-OUT;n:type:ShaderForge.SFN_Get,id:6410,x:37035,y:37817,varname:node_6410,prsc:2|IN-9491-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:1368,x:39460,y:34439,ptovrint:False,ptlb:AdditiveOrBlend,ptin:_AdditiveOrBlend,varname:node_1368,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-3472-OUT,B-791-OUT;n:type:ShaderForge.SFN_Multiply,id:5658,x:38758,y:34295,varname:node_5658,prsc:2|A-8880-OUT,B-6206-OUT;n:type:ShaderForge.SFN_Add,id:791,x:39002,y:34359,varname:node_791,prsc:2|A-387-OUT,B-5658-OUT;n:type:ShaderForge.SFN_Get,id:6206,x:38535,y:34295,varname:node_6206,prsc:2|IN-544-OUT;n:type:ShaderForge.SFN_Get,id:8880,x:38547,y:34234,varname:node_8880,prsc:2|IN-4522-OUT;n:type:ShaderForge.SFN_Lerp,id:4022,x:39680,y:34359,varname:node_4022,prsc:2|A-1368-OUT,B-1339-OUT,T-8003-OUT;n:type:ShaderForge.SFN_Get,id:8003,x:39419,y:34343,varname:node_8003,prsc:2|IN-9491-OUT;n:type:ShaderForge.SFN_Get,id:1339,x:39419,y:34290,varname:node_1339,prsc:2|IN-4233-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:3063,x:39902,y:34341,ptovrint:False,ptlb:CloudsHaveFog,ptin:_CloudsHaveFog,varname:node_3063,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-1368-OUT,B-4022-OUT;n:type:ShaderForge.SFN_Clamp01,id:9115,x:40110,y:34369,varname:node_9115,prsc:2|IN-3063-OUT;n:type:ShaderForge.SFN_Code,id:4171,x:37165,y:35969,varname:node_4171,prsc:2,code:ZgBsAG8AYQB0ACAAbQBpAGQAcABvAGkAbgB0ACAAPQAgAHAAbwB3ACgAMAAuADUALAAgADIALgAyACkAOwAKAHIAZQB0AHUAcgBuACAAKABJAG4AIAAtACAAbQBpAGQAcABvAGkAbgB0ACkAIAAqACAAQwBvAG4AdAByAGEAcwB0ACAAKwAgAG0AaQBkAHAAbwBpAG4AdAA7AA==,output:2,fname:contrast,width:367,height:112,input:2,input:0,input_1_label:In,input_2_label:Contrast|A-8818-RGB,B-5799-OUT;n:type:ShaderForge.SFN_Slider,id:5799,x:36795,y:36175,ptovrint:False,ptlb:CloudsContrast,ptin:_CloudsContrast,varname:node_5799,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Clamp01,id:5124,x:37436,y:37885,varname:node_5124,prsc:2|IN-5455-OUT;proporder:317-5106-6998-4841-1472-5202-1707-2088-6621-2630-1796-6572-6963-8818-1368-8014-2701-8968-9403-5799-2-7064-3153-5981-3063-7339-7777-7230-9134-9528-3616;pass:END;sub:END;*/

Shader "NFS3Importer/Legacy/Skybox" {
    Properties {
        _SkyColor ("SkyColor", Color) = (0.3529412,0.6470588,1,1)
        _HorizonColor ("HorizonColor", Color) = (0.8666667,0.8666667,0.8666667,1)
        _GroundColor ("GroundColor", Color) = (0.282353,0.282353,0.282353,1)
        _HorizonSharpnessSky ("HorizonSharpnessSky", Float ) = 5
        _HorizonSharpnessGround ("HorizonSharpnessGround", Float ) = 2
        _AmbientColorSunSide ("AmbientColorSunSide", Color) = (1,0.827451,0.4156863,1)
        _AmbientColorSunOpposite ("AmbientColorSunOpposite", Color) = (1,0.827451,0.4156863,1)
        _AmbientColorSharpness ("AmbientColorSharpness", Float ) = 10
        _HorizonOffset ("HorizonOffset", Range(-1, 1)) = 0
        _SkyIntensity ("SkyIntensity", Range(0, 1)) = 1
        _SunRadius ("SunRadius", Range(0, 1)) = 0.05
        _SunFalloff ("SunFalloff", Range(0.001, 1)) = 0.02
        _SunIntensity ("SunIntensity", Range(0, 1)) = 1
        [NoScaleOffset]_CloudsTexture ("CloudsTexture", 2D) = "black" {}
        [MaterialToggle] _AdditiveOrBlend ("AdditiveOrBlend", Float ) = 0.8666667
        _CloudsTiling ("CloudsTiling", Float ) = 1
        _CloudsFarTiling ("CloudsFarTiling", Float ) = 0
        _CloudsOffset ("CloudsOffset", Vector) = (0,0,0,0)
        _CloudsBrightness ("CloudsBrightness", Range(0, 1)) = 1
        _CloudsContrast ("CloudsContrast", Range(0, 1)) = 1
        _CloudsColor ("CloudsColor", Color) = (0.5,0.5,0.5,1)
        _CloudsCutoff ("CloudsCutoff", Range(0, 1)) = 0
        _CloudsFalloff ("CloudsFalloff", Range(0.001, 10)) = 0.001
        _CloudsOpacity ("CloudsOpacity", Range(0, 1)) = 1
        [MaterialToggle] _CloudsHaveFog ("CloudsHaveFog", Float ) = 0.1280277
        [NoScaleOffset]_PixMap ("PixMap", 2D) = "black" {}
        _PixMapColor ("PixMapColor", Color) = (1,1,1,1)
        _PixMapOffset ("PixMapOffset", Float ) = 0
        _PixMapTilingV ("PixMapTilingV", Float ) = 1
        _PixMapTilingU ("PixMapTilingU", Float ) = 1
        _FogIntensityOnSkybox ("FogIntensityOnSkybox", Range(0, 1)) = 0.1
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
            "PreviewType"="Skybox"
        }
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _CloudsTexture;
            uniform sampler2D _PixMap;
            float3 contrast( float3 In , float Contrast ){
            float midpoint = pow(0.5, 2.2);
            return (In - midpoint) * Contrast + midpoint;
            }
            
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float, _HorizonSharpnessSky)
                UNITY_DEFINE_INSTANCED_PROP( float, _HorizonSharpnessGround)
                UNITY_DEFINE_INSTANCED_PROP( float4, _HorizonColor)
                UNITY_DEFINE_INSTANCED_PROP( float4, _SkyColor)
                UNITY_DEFINE_INSTANCED_PROP( float4, _GroundColor)
                UNITY_DEFINE_INSTANCED_PROP( float4, _AmbientColorSunSide)
                UNITY_DEFINE_INSTANCED_PROP( float4, _AmbientColorSunOpposite)
                UNITY_DEFINE_INSTANCED_PROP( float, _AmbientColorSharpness)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsFarTiling)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsTiling)
                UNITY_DEFINE_INSTANCED_PROP( float4, _CloudsOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsBrightness)
                UNITY_DEFINE_INSTANCED_PROP( float4, _CloudsColor)
                UNITY_DEFINE_INSTANCED_PROP( float, _PixMapOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _PixMapTilingV)
                UNITY_DEFINE_INSTANCED_PROP( float, _PixMapTilingU)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsCutoff)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsOpacity)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsFalloff)
                UNITY_DEFINE_INSTANCED_PROP( float, _HorizonOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _SkyIntensity)
                UNITY_DEFINE_INSTANCED_PROP( float, _SunRadius)
                UNITY_DEFINE_INSTANCED_PROP( float, _SunFalloff)
                UNITY_DEFINE_INSTANCED_PROP( float, _SunIntensity)
                UNITY_DEFINE_INSTANCED_PROP( float4, _PixMapColor)
                UNITY_DEFINE_INSTANCED_PROP( float, _FogIntensityOnSkybox)
                UNITY_DEFINE_INSTANCED_PROP( fixed, _AdditiveOrBlend)
                UNITY_DEFINE_INSTANCED_PROP( fixed, _CloudsHaveFog)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsContrast)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 posWorld : TEXCOORD0;
                LIGHTING_COORDS(1,2)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float _SunRadius_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SunRadius );
                float node_7106 = _SunRadius_var;
                float node_8355 = (1.0 - (node_7106*node_7106));
                float _SunFalloff_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SunFalloff );
                float node_1286 = (_SunRadius_var+_SunFalloff_var);
                float node_4463 = 1.0;
                float node_6516 = 1.0;
                float _HorizonOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonOffset );
                float3 NWorldPos = normalize(i.posWorld.rgb);
                float node_1819 = NWorldPos.g;
                float node_4072 = saturate(min(node_6516,(node_6516-((-1*_HorizonOffset_var)+node_1819))));
                float _HorizonSharpnessSky_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonSharpnessSky );
                float node_3209 = (1.0 - pow(node_4072,abs(_HorizonSharpnessSky_var)));
                float SkyMask = node_3209;
                float _SunIntensity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SunIntensity );
                float3 Sun = ((_LightColor0.rgb*(saturate((node_4463 + ( (saturate(dot(normalize(viewDirection),(-1*lightDirection))) - node_8355) * (0.0 - node_4463) ) / ((1.0 - (node_1286*node_1286)) - node_8355)))*SkyMask))*_SunIntensity_var);
                float4 _AmbientColorSunOpposite_var = UNITY_ACCESS_INSTANCED_PROP( Props, _AmbientColorSunOpposite );
                float2 node_6931 = normalize(viewDirection.rb);
                float _AmbientColorSharpness_var = UNITY_ACCESS_INSTANCED_PROP( Props, _AmbientColorSharpness );
                float node_4080 = pow(node_4072,abs(_AmbientColorSharpness_var));
                float SunSideMaskOpposite = ((1.0 - saturate(dot(node_6931,normalize((-1*lightDirection).rb))))*node_4080*node_3209);
                float4 _AmbientColorSunSide_var = UNITY_ACCESS_INSTANCED_PROP( Props, _AmbientColorSunSide );
                float SunSideMask = ((1.0 - saturate(dot(node_6931,normalize(lightDirection.rb))))*node_3209*node_4080);
                float4 _SkyColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SkyColor );
                float4 _HorizonColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonColor );
                float node_5407 = 1.0;
                float _HorizonSharpnessGround_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonSharpnessGround );
                float GroundMask = (1.0 - pow(min(node_5407,(node_5407+node_1819)),abs(_HorizonSharpnessGround_var)));
                float node_2490 = GroundMask;
                float4 _GroundColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _GroundColor );
                float _SkyIntensity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SkyIntensity );
                float3 Gradient = (((_AmbientColorSunOpposite_var.rgb*SunSideMaskOpposite)+((_AmbientColorSunSide_var.rgb*SunSideMask)+(((_SkyColor_var.rgb*SkyMask*(1.0 - SunSideMask)*(1.0 - SunSideMaskOpposite))+(_HorizonColor_var.rgb*((1.0 - SkyMask)-node_2490)))+(_GroundColor_var.rgb*node_2490))))*_SkyIntensity_var);
                float3 node_387 = (Sun+Gradient);
                float3 node_3809 = NWorldPos.rgb;
                float node_6897 = 0.0;
                float node_2864 = 1.0;
                float _CloudsFarTiling_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsFarTiling );
                float node_7798 = abs(_CloudsFarTiling_var);
                float _CloudsTiling_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsTiling );
                float4 _CloudsOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsOffset );
                float2 node_1782 = (((float2(node_3809.r,node_3809.b)/(node_7798 + ( (abs(node_3809.g) - node_6897) * (node_2864 - node_7798) ) / (node_2864 - node_6897)))*_CloudsTiling_var)+float2(_CloudsOffset_var.r,_CloudsOffset_var.g));
                float4 _CloudsTexture_var = tex2D(_CloudsTexture,node_1782);
                float _CloudsContrast_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsContrast );
                float _CloudsBrightness_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsBrightness );
                float4 _CloudsColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsColor );
                float3 Clouds = ((contrast( _CloudsTexture_var.rgb , _CloudsContrast_var )+(_CloudsBrightness_var-1.0))*saturate(( _CloudsColor_var.rgb > 0.5 ? (1.0-(1.0-2.0*(_CloudsColor_var.rgb-0.5))*(1.0-_LightColor0.rgb)) : (2.0*_CloudsColor_var.rgb*_LightColor0.rgb) )));
                float _CloudsCutoff_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsCutoff );
                float _CloudsFalloff_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsFalloff );
                float _CloudsOpacity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsOpacity );
                float CloudMask = ((_CloudsTexture_var.a*pow(saturate((node_3809.g+(-1*_CloudsCutoff_var))),_CloudsFalloff_var))*_CloudsOpacity_var);
                float3 _AdditiveOrBlend_var = lerp( lerp(node_387,saturate(( Clouds > 0.5 ? (1.0-(1.0-2.0*(Clouds-0.5))*(1.0-node_387)) : (2.0*Clouds*node_387) )),CloudMask), (node_387+(Clouds*CloudMask)), UNITY_ACCESS_INSTANCED_PROP( Props, _AdditiveOrBlend ) );
                float3 FogColor = unity_FogColor.rgb;
                float _FogIntensityOnSkybox_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FogIntensityOnSkybox );
                float FogIntensity = _FogIntensityOnSkybox_var;
                float3 _CloudsHaveFog_var = lerp( _AdditiveOrBlend_var, lerp(_AdditiveOrBlend_var,FogColor,FogIntensity), UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsHaveFog ) );
                float3 node_8144 = NWorldPos.rgb;
                float _PixMapTilingU_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapTilingU );
                float _PixMapOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapOffset );
                float _PixMapTilingV_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapTilingV );
                float2 node_9079 = float2(((atan2(node_8144.r,node_8144.b)/6.28318530718)*_PixMapTilingU_var),(((asin(node_8144.g)/(3.141592654/2.0))+(-1*_PixMapOffset_var))*_PixMapTilingV_var));
                float4 _PixMap_var = tex2D(_PixMap,node_9079);
                float PixMapMask = _PixMap_var.a;
                float node_2409 = PixMapMask;
                float4 _PixMapColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapColor );
                float3 PixMap = saturate(lerp((_PixMapColor_var.rgb*_PixMap_var.rgb),FogColor,FogIntensity));
                float3 BeforeDithering = ((saturate(_CloudsHaveFog_var)*(1.0 - node_2409))+(node_2409*PixMap));
                float3 finalColor = BeforeDithering;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _CloudsTexture;
            uniform sampler2D _PixMap;
            float3 contrast( float3 In , float Contrast ){
            float midpoint = pow(0.5, 2.2);
            return (In - midpoint) * Contrast + midpoint;
            }
            
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float, _HorizonSharpnessSky)
                UNITY_DEFINE_INSTANCED_PROP( float, _HorizonSharpnessGround)
                UNITY_DEFINE_INSTANCED_PROP( float4, _HorizonColor)
                UNITY_DEFINE_INSTANCED_PROP( float4, _SkyColor)
                UNITY_DEFINE_INSTANCED_PROP( float4, _GroundColor)
                UNITY_DEFINE_INSTANCED_PROP( float4, _AmbientColorSunSide)
                UNITY_DEFINE_INSTANCED_PROP( float4, _AmbientColorSunOpposite)
                UNITY_DEFINE_INSTANCED_PROP( float, _AmbientColorSharpness)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsFarTiling)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsTiling)
                UNITY_DEFINE_INSTANCED_PROP( float4, _CloudsOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsBrightness)
                UNITY_DEFINE_INSTANCED_PROP( float4, _CloudsColor)
                UNITY_DEFINE_INSTANCED_PROP( float, _PixMapOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _PixMapTilingV)
                UNITY_DEFINE_INSTANCED_PROP( float, _PixMapTilingU)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsCutoff)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsOpacity)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsFalloff)
                UNITY_DEFINE_INSTANCED_PROP( float, _HorizonOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _SkyIntensity)
                UNITY_DEFINE_INSTANCED_PROP( float, _SunRadius)
                UNITY_DEFINE_INSTANCED_PROP( float, _SunFalloff)
                UNITY_DEFINE_INSTANCED_PROP( float, _SunIntensity)
                UNITY_DEFINE_INSTANCED_PROP( float4, _PixMapColor)
                UNITY_DEFINE_INSTANCED_PROP( float, _FogIntensityOnSkybox)
                UNITY_DEFINE_INSTANCED_PROP( fixed, _AdditiveOrBlend)
                UNITY_DEFINE_INSTANCED_PROP( fixed, _CloudsHaveFog)
                UNITY_DEFINE_INSTANCED_PROP( float, _CloudsContrast)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 posWorld : TEXCOORD0;
                LIGHTING_COORDS(1,2)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float _SunRadius_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SunRadius );
                float node_7106 = _SunRadius_var;
                float node_8355 = (1.0 - (node_7106*node_7106));
                float _SunFalloff_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SunFalloff );
                float node_1286 = (_SunRadius_var+_SunFalloff_var);
                float node_4463 = 1.0;
                float node_6516 = 1.0;
                float _HorizonOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonOffset );
                float3 NWorldPos = normalize(i.posWorld.rgb);
                float node_1819 = NWorldPos.g;
                float node_4072 = saturate(min(node_6516,(node_6516-((-1*_HorizonOffset_var)+node_1819))));
                float _HorizonSharpnessSky_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonSharpnessSky );
                float node_3209 = (1.0 - pow(node_4072,abs(_HorizonSharpnessSky_var)));
                float SkyMask = node_3209;
                float _SunIntensity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SunIntensity );
                float3 Sun = ((_LightColor0.rgb*(saturate((node_4463 + ( (saturate(dot(normalize(viewDirection),(-1*lightDirection))) - node_8355) * (0.0 - node_4463) ) / ((1.0 - (node_1286*node_1286)) - node_8355)))*SkyMask))*_SunIntensity_var);
                float4 _AmbientColorSunOpposite_var = UNITY_ACCESS_INSTANCED_PROP( Props, _AmbientColorSunOpposite );
                float2 node_6931 = normalize(viewDirection.rb);
                float _AmbientColorSharpness_var = UNITY_ACCESS_INSTANCED_PROP( Props, _AmbientColorSharpness );
                float node_4080 = pow(node_4072,abs(_AmbientColorSharpness_var));
                float SunSideMaskOpposite = ((1.0 - saturate(dot(node_6931,normalize((-1*lightDirection).rb))))*node_4080*node_3209);
                float4 _AmbientColorSunSide_var = UNITY_ACCESS_INSTANCED_PROP( Props, _AmbientColorSunSide );
                float SunSideMask = ((1.0 - saturate(dot(node_6931,normalize(lightDirection.rb))))*node_3209*node_4080);
                float4 _SkyColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SkyColor );
                float4 _HorizonColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonColor );
                float node_5407 = 1.0;
                float _HorizonSharpnessGround_var = UNITY_ACCESS_INSTANCED_PROP( Props, _HorizonSharpnessGround );
                float GroundMask = (1.0 - pow(min(node_5407,(node_5407+node_1819)),abs(_HorizonSharpnessGround_var)));
                float node_2490 = GroundMask;
                float4 _GroundColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _GroundColor );
                float _SkyIntensity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _SkyIntensity );
                float3 Gradient = (((_AmbientColorSunOpposite_var.rgb*SunSideMaskOpposite)+((_AmbientColorSunSide_var.rgb*SunSideMask)+(((_SkyColor_var.rgb*SkyMask*(1.0 - SunSideMask)*(1.0 - SunSideMaskOpposite))+(_HorizonColor_var.rgb*((1.0 - SkyMask)-node_2490)))+(_GroundColor_var.rgb*node_2490))))*_SkyIntensity_var);
                float3 node_387 = (Sun+Gradient);
                float3 node_3809 = NWorldPos.rgb;
                float node_6897 = 0.0;
                float node_2864 = 1.0;
                float _CloudsFarTiling_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsFarTiling );
                float node_7798 = abs(_CloudsFarTiling_var);
                float _CloudsTiling_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsTiling );
                float4 _CloudsOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsOffset );
                float2 node_1782 = (((float2(node_3809.r,node_3809.b)/(node_7798 + ( (abs(node_3809.g) - node_6897) * (node_2864 - node_7798) ) / (node_2864 - node_6897)))*_CloudsTiling_var)+float2(_CloudsOffset_var.r,_CloudsOffset_var.g));
                float4 _CloudsTexture_var = tex2D(_CloudsTexture,node_1782);
                float _CloudsContrast_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsContrast );
                float _CloudsBrightness_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsBrightness );
                float4 _CloudsColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsColor );
                float3 Clouds = ((contrast( _CloudsTexture_var.rgb , _CloudsContrast_var )+(_CloudsBrightness_var-1.0))*saturate(( _CloudsColor_var.rgb > 0.5 ? (1.0-(1.0-2.0*(_CloudsColor_var.rgb-0.5))*(1.0-_LightColor0.rgb)) : (2.0*_CloudsColor_var.rgb*_LightColor0.rgb) )));
                float _CloudsCutoff_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsCutoff );
                float _CloudsFalloff_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsFalloff );
                float _CloudsOpacity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsOpacity );
                float CloudMask = ((_CloudsTexture_var.a*pow(saturate((node_3809.g+(-1*_CloudsCutoff_var))),_CloudsFalloff_var))*_CloudsOpacity_var);
                float3 _AdditiveOrBlend_var = lerp( lerp(node_387,saturate(( Clouds > 0.5 ? (1.0-(1.0-2.0*(Clouds-0.5))*(1.0-node_387)) : (2.0*Clouds*node_387) )),CloudMask), (node_387+(Clouds*CloudMask)), UNITY_ACCESS_INSTANCED_PROP( Props, _AdditiveOrBlend ) );
                float3 FogColor = unity_FogColor.rgb;
                float _FogIntensityOnSkybox_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FogIntensityOnSkybox );
                float FogIntensity = _FogIntensityOnSkybox_var;
                float3 _CloudsHaveFog_var = lerp( _AdditiveOrBlend_var, lerp(_AdditiveOrBlend_var,FogColor,FogIntensity), UNITY_ACCESS_INSTANCED_PROP( Props, _CloudsHaveFog ) );
                float3 node_8144 = NWorldPos.rgb;
                float _PixMapTilingU_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapTilingU );
                float _PixMapOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapOffset );
                float _PixMapTilingV_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapTilingV );
                float2 node_9079 = float2(((atan2(node_8144.r,node_8144.b)/6.28318530718)*_PixMapTilingU_var),(((asin(node_8144.g)/(3.141592654/2.0))+(-1*_PixMapOffset_var))*_PixMapTilingV_var));
                float4 _PixMap_var = tex2D(_PixMap,node_9079);
                float PixMapMask = _PixMap_var.a;
                float node_2409 = PixMapMask;
                float4 _PixMapColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _PixMapColor );
                float3 PixMap = saturate(lerp((_PixMapColor_var.rgb*_PixMap_var.rgb),FogColor,FogIntensity));
                float3 BeforeDithering = ((saturate(_CloudsHaveFog_var)*(1.0 - node_2409))+(node_2409*PixMap));
                float3 finalColor = BeforeDithering;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
