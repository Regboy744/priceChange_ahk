categories := Map(
    "D0024 - GROCERY -  IMPULSE", Map(
        "S0001 - IMPULSE CONFECTIONERY", Map(
            "C0001 - CHOCOLATE", ["F0699", "F0001", "F0002", "F0004", "F0005", "F0006", "F0007"],
            "C0002 - SUGAR CONFECTIONERY", ["F0008", "F0009", "F0010", "F0011", "F0012", "F0013"],
            "C0003 - CHEWING GUM", ["F0014", "F0015", "F0016"],
            "C0004 - MINTS", ["F0017", "F0018", "F0019", "F0020"],
            "C0005 - MEDICAL CONFECTIONERY", ["F0021"],
            "C0006 - KIDS CONFECTIONERY", ["F0022", "F0023", "F0024", "F0025", "F0026", "F0027"],
            "C0007 - PICK & MIX", ["F0028", "F0029", "F0030"],
            "C0700 - SNACKING CONFECTIONARY", ["F3511"]
        ),
        "S0002 - IMPULSE CRISPS AND SNACKS", Map(
            "C0008 - IMPULSE CRISPS", ["F0032", "F0033", "F0034", "F0035"],
            "C0009 - IMPULSE SNACK", ["F0036", "F0037", "F0038", "F0039"],
            "C0010 - IMPULSE POPCORN", ["F0041", "F0043", "F0044", "F0045"],
            "C0011 - IMPULSE NUTS", ["F0046", "F0047", "F0048", "F0049", "F0050", "F0051"],
            "C0012 - IMPULSE DRIED FRUIT", ["F0052"]
        ),
        "S0003 - IMPULSE SOFT DRINKS", Map(
            "C0013 - IMPULSE CARBONATES", ["F0053", "F0054", "F0055", "F0056", "F0057", "F0058", "F0059", "F0060",
                "F5286"],
            "C0014 - IMPULSE ENERGY DRINKS", ["F0061", "F0062", "F0063"],
            "C0015 - IMPULSE READY TO DRINK", ["F0065", "F0066", "F0067"],
            "C0016 - IMPULSE WATER", ["F0069", "F0070", "F0071", "F0072", "F0073", "F5287", "F5289", "F5290", "F5291",
                "F5356"],
            "C0017 - IMPULSE ADULT DRINKS", ["F0074", "F0075", "F0076", "F5296", "F5297", "F5353"],
            "C0018 - IMPULSE JUICE & SMOOTHIES", ["F0077", "F0078", "F0080", "F0081", "F5043", "F5298"]
        ),
        "S0004 - MULTIPACK CRISPS & SNACKS", Map(
            "C0019 - MULTIPACK CRISPS", ["F0083", "F0084", "F0085", "F0086"],
            "C0020 - MULTIPACK SNACKS", ["F0087", "F0088", "F0089"],
            "C0021 - MULTIPACK POPCORN", ["F0091", "F0092", "F0093"],
            "C0022 - MULTIPACK NUTS & FRUIT", ["F0100"],
            "C0023 - SEASONAL CRISPS AND NUTS", ["F0102", "F0103", "F0104", "F0105", "F0106"]
        ),
        "S0005 - SHARING CRISPS AND SNACKS", Map(
            "C0024 - SHARING CRISPS", ["F0107", "F0108", "F0109", "F0110"],
            "C0025 - SHARING SNACKS", ["F0111", "F0112", "F0113"],
            "C0026 - SHARING POPCORN", ["F0116", "F0117", "F0118"],
            "C0027 - SHARING NUTS", ["F0120", "F0121", "F0122", "F0123", "F0124", "F0125"],
            "C0028 - DIPS", ["F0128", "F0129"]
        ),
        "S0006 - TAKE HOME CONFECTIONERY", Map(
            "C0029 - BOXED CONFECTIONERY", ["F0131", "F0132", "F0133", "F0134", "F0135", "F0136", "F0137", "F0138"],
            "C0030 - BLOCK CHOCOLATE", ["F0139", "F0140", "F0141"],
            "C0031 - FUNSIZE CONFECTIONERY", ["F0142", "F0143", "F0144", "F0145"],
            "C0032 - MULTIPACK CONFECTIONERY", ["F0146", "F0147", "F0148", "F0150", "F0151", "F0152"],
            "C0033 - CONFECTIONERY BAGS", ["F0153", "F0154", "F0157"],
            "C0034 - CHEWING GUM - TAKEHOME", ["F0158", "F0159"],
            "C0035 - SEASONAL CONF - CHRISTMAS", ["F0160", "F0161", "F0162", "F0163", "F0164", "F3231", "F5115"],
            "C0036 - SEASONAL CONF - EASTER", ["F0165", "F0166", "F0167", "F0168", "F5116"],
            "C0645 - SEASONAL CONF - OTHER SEASONS", ["F3228", "F3229", "F3230"]
        ),
        "S0008 - TAKE HOME SOFT DRINKS", Map(
            "C0040 - TAKE HOME CARBONATES", ["F0184", "F0185", "F0186", "F0187", "F0188", "F0189", "F0190", "F3525",
                "F3526", "F5299", "F5300", "F5301", "F5302", "F5357"],
            "C0041 - TAKE HOME ENERGY DRINKS", ["F0191", "F0193", "F5303"],
            "C0042 - TAKE HOME READY TO DRINK", ["F0194", "F0195", "F0196", "F0198", "F0199", "F5305", "F5307", "F5308"],
            "C0043 - TAKE HOME WATER", ["F0200", "F0201", "F0202", "F0203", "F0204", "F5309", "F5310", "F5311"],
            "C0044 - TAKE HOME PREMIUM", ["F0206", "F0207"],
            "C0045 - DILUTE & CORDIAL", ["F0209", "F0211", "F0212", "F0213", "F0214", "F0215", "F5312"],
            "C0046 - MIXERS", ["F0216", "F0217", "F0218", "F0219", "F0220", "F5313", "F5314", "F5317", "F5319", "F5320"]
        ),
        "S1000001 - NON SCAN GROCERY IMPULSE", Map(
            "C1000001 - NON SCAN GROCERY IMPULSE", ["F1000001"]
        )
    ),
    "D0025 - GROCERY - EDIBLE", Map(
        "S0010 - BISCUITS", Map(
            "C0051 - CHILDREN'S BISCUITS", ["F0243", "F0245", "F0246"],
            "C0052 - EVERYDAY BISCUIT", ["F0247", "F0248", "F0249", "F0250", "F0251", "F0252", "F0253", "F0254"],
            "C0053 - EVERYDAY BISCUIT TREAT", ["F0255", "F0256", "F0257", "F0258", "F0259", "F0260", "F0261", "F0262",
                "F0263"],
            "C0054 - HEALTHIER BISCUITS", ["F0264", "F0265", "F0266", "F0267"],
            "C0055 - IMPULSE BISCUITS", ["F0268", "F0269", "F0271"],
            "C0056 - SAVOURY BISCUITS", ["F0272", "F0273", "F0274", "F0275", "F0276", "F0278", "F0279"],
            "C0057 - SEASONAL TIN/BOXED BISCUITS", ["F0280", "F0281", "F0282", "F0283", "F0284", "F3235"],
            "C0058 - SPECIAL BISCUIT TREATS", ["F0285", "F0286", "F0287", "F0288", "F0289", "F0290", "F0291", "F0292"],
            "C0655 - BISCUIT BARS", ["F3330", "F3331", "F3332"]
        ),
        "S0011 - BREAKFAST CEREALS", Map(
            "C0059 - ADULT CEREALS", ["F0293", "F0294", "F0296", "F5045"],
            "C0060 - BULK CEREALS", [],
            "C0061 - CEREAL ACCOMPANIMENTS", ["F0298", "F0300", "F0301"],
            "C0062 - CEREAL BARS", ["F0302", "F0303"],
            "C0063 - CHILDREN CEREALS", ["F0306", "F0307", "F0309", "F0310", "F0311"],
            "C0064 - CONVENIENCE CEREALS", ["F0313", "F0314", "F0315", "F3234"],
            "C0065 - CORN CEREALS", ["F0316", "F0317", "F0319"],
            "C0066 - HOT CEREALS", ["F0320", "F0321"],
            "C0067 - MUESLI CEREALS", ["F0322", "F0323", "F0324", "F0325"],
            "C0068 - WHEAT CEREAL", ["F0326", "F0327"]
        ),
        "S0012 - CANNED DRIED VEG/MEAT", Map(
            "C0069 - BAKED BEANS", ["F0329", "F0330", "F0331", "F0332", "F0333"],
            "C0070 - CANNED BEANS & PULSES", ["F0335", "F0336", "F0337", "F0338", "F0339"],
            "C0071 - CANNED PASTA", ["F0342", "F0344", "F0345"],
            "C0072 - CANNED READY MEALS", [],
            "C0073 - CANNED CARROTS", ["F0349", "F0353"],
            "C0074 - CANNED CORN", ["F0356", "F0357", "F0359"],
            "C0075 - AMBIENT DRIED VEG", ["F0362", "F0363", "F0364", "F0366"],
            "C0076 - OTHER CANNED VEG", ["F0367", "F0369", "F0371", "F0372"],
            "C0077 - CANNED PEAS", ["F0374", "F0375", "F0377", "F0378"],
            "C0078 - CANNED POTATOES", [],
            "C0079 - CANNED TOMATOES", [],
            "C0939 - CANNED MEAT & SPREADS", ["F5403", "F5404", "F5405"]
        ),
        "S0013 - CANNED FISH", Map(
            "C0082 - OTHER CANNED FISH", ["F0402", "F0403", "F0405", "F0406"],
            "C0083 - CANNED SALMON", ["F0408", "F0409", "F0410"],
            "C0084 - CANNED SARDINES", ["F0412"],
            "C0085 - CANNED TUNA", ["F0415", "F0417", "F0418", "F0419", "F0420"]
        ),
        "S0014 - CANNED FRUIT/DESSERTS", Map(
            "C0086 - CANNED FRUIT", ["F0428", "F0429", "F0430", "F0432", "F0433", "F0434", "F0435", "F0436", "F0437"],
            "C0087 - AMBIENT DESSERTS", ["F0440", "F0446", "F0447", "F0448", "F0450", "F0451", "F0452", "F0453"],
            "C0088 - ICE CREAM SUNDRIES", ["F0455", "F0456", "F0457", "F0458"],
            "C0089 - TOPPINGS", ["F0459", "F0460", "F0461"]
        ),
        "S0015 - CONDIMENTS TABLE TOP", Map(
            "C0090 - CATERING COOKING SAUCES", ["F0462"],
            "C0091 - CATERING SAVOURY PORTION PACKS", [],
            "C0092 - CHUTNEY & RELISH", ["F0472", "F0474", "F0475", "F0476"],
            "C0093 - CONDIMENT SAUCES", ["F0477", "F0479", "F0480", "F0481", "F0483", "F0484", "F0485"],
            "C0094 - CROUTONS", ["F0487", "F0488"],
            "C0095 - AMBIENT DRESSINGS", ["F0490", "F0491", "F0493"],
            "C0096 - AMBIENT GRAVY & STOCK", [],
            "C0097 - AMBIENT HERBS & SPICES", ["F0513", "F3237"],
            "C0098 - KETCHUP", ["F0516", "F0517"],
            "C0099 - MARINADES", ["F0518"],
            "C0100 - MAYONNAISE", ["F0520", "F0521", "F0522", "F0523", "F0524"],
            "C0101 - MUSTARD", ["F0526", "F0527", "F0529"],
            "C0102 - AMBIENT OLIVES", ["F0531", "F0532", "F0533"],
            "C0103 - PICKLES", ["F0535", "F0538", "F0539", "F0540"],
            "C0104 - SALT AND PEPPER", ["F0544", "F0545"],
            "C0105 - AMBIENT STUFFING", ["F0548"],
            "C0106 - TABLE SAUCES", ["F0549", "F0552", "F0553"],
            "C0107 - VINEGAR", ["F0554", "F0557", "F0559", "F0560"]
        ),
        "S0016 - HW FREE FROM", Map(
            "C0108 - HW AMBIENT SUGAR FREE", ["F0561"],
            "C0109 - HW AMBIENT GLUTEN FREE", ["F0565", "F0566", "F0567", "F0568", "F4570"],
            "C0110 - HW DAIRY FREE", ["F0569"],
            "C0111 - HW AMBIENT SLIMMING & DIET", ["F0572"],
            "C0917 - HW WHEAT FREE", ["F5229"],
            "C0918 - HW HEALTHIER SNACKING", ["F5230", "F5231", "F5232"]
        ),
        "S0017 - HOME BAKING", Map(
            "C0112 - BAKING INGREDIENTS & AGENTS", ["F0578", "F0581", "F0582", "F0583", "F0584", "F0585", "F0586"],
            "C0113 - CAKE DEC, CANDLES & CASES", ["F0588", "F0589", "F0590", "F0591", "F0594", "F0595"],
            "C0114 - HOMEBAKING FRUIT", ["F0596", "F0598", "F0601", "F0602"],
            "C0116 - FLOUR", ["F0609", "F0610", "F0611", "F0612", "F0613"],
            "C0117 - HOMEBAKING MIXES", ["F0614", "F0615", "F0619", "F0620"],
            "C0118 - HOMEBAKING NUTS & SEEDS", ["F0624", "F0626"]
        ),
        "S0018 - HOT BEVERAGES", Map(
            "C0119 - HOT BEVERAGES", ["F0629", "F0630", "F0631", "F0632", "F0633", "F0634"],
            "C0120 - COFFEES", ["F0635", "F0636", "F0637", "F0638", "F0639", "F0640", "F0641", "F0642", "F3233",
                "F5029"],
            "C0121 - TEA", ["F0647", "F0648", "F0649", "F0650", "F0651", "F0652", "F0653", "F0654", "F0655", "F0656",
                "F5030"]
        ),
        "S0019 - INSTANT HOT SNACKS", Map(
            "C0122 - AMBIENT INSTANT HOT SNACKS", ["F0657", "F0658", "F0659", "F0660", "F0661"]
        ),
        "S0020 - FOODS OF THE WORLD", Map(
            "C0123 - BULK INT RTU SAUCES & INGREDIENTS", [],
            "C0124 - CHINESE AMBIENT FOODS", ["F0674", "F0676", "F0677", "F0678", "F0679", "F0681"],
            "C0125 - DRY PACKET SAUCES", ["F0685", "F0686"],
            "C0126 - GREEK AMBIENT FOODS", ["F0687", "F0693"],
            "C0127 - INDIAN AMBIENT FOODS", ["F0694", "F0696", "F0697", "F0698", "F0699", "F0700", "F0701", "F0702"],
            "C0129 - JAPANESE AMBIENT FOODS", ["F0715", "F0717"],
            "C0130 - KOSHER AMBIENT FOODS", ["F0723"],
            "C0131 - MEDITERRANEAN AMBIENT FOODS", ["F0726"],
            "C0132 - MEXICAN AMBIENT FOODS", ["F0731", "F0734", "F0735", "F0736", "F0737", "F0739", "F0741"],
            "C0133 - OTHER INTERNATIONAL AMBIENT FOODS", ["F0742", "F0743", "F0744", "F0745", "F0748"],
            "C0134 - THAI AMBIENT FOODS", ["F0750", "F0751", "F0752", "F0753"],
            "C0135 - TRADITIONAL AMBIENT FOODS", ["F0757"],
            "C0827 - COUSCOUS", ["F4178"],
            "C0828 - AMBIENT NOODLES", ["F4181", "F4183"],
            "C0829 - RICE", ["F4184", "F4185", "F4186", "F4188", "F4189", "F4190", "F4191", "F4192", "F4193"]
        ),
        "S0021 - OILS", Map(
            "C0136 - COOKING OIL", ["F0761", "F0763", "F0764", "F0765", "F0766", "F5395"],
            "C0137 - OLIVE OIL", ["F0768", "F0769", "F0770", "F0771", "F0772"],
            "C0138 - SPECIALITY OIL", ["F0776", "F0778", "F0779"]
        ),
        "S0022 - ITALIAN", Map(
            "C0140 - DRY PASTA", ["F0786", "F0787", "F0788", "F0789", "F0790", "F0791"],
            "C0826 - ITALIAN AMBIENT FOODS", ["F4168", "F4170", "F4171", "F4173", "F4174", "F4175", "F4176", "F4177"],
            "C0833 - TINNED TOMATOES", ["F4259"]
        ),
        "S0023 - PRESERVES", Map(
            "C0141 - HONEY", ["F0792", "F0793", "F0794", "F0795"],
            "C0142 - JAMS", ["F0798", "F0799", "F0800", "F0801", "F0802"],
            "C0143 - MARMALADES", ["F0805", "F0806", "F0807", "F0808", "F0809", "F0810", "F0811"],
            "C0144 - PEANUT BUTTER", ["F0812", "F0813", "F0814", "F0815"],
            "C0145 - AMBIENT SAVOURY SPREADS", ["F0816", "F0817"],
            "C0146 - AMBIENT SPREADS", ["F0818", "F0819", "F0822"]
        ),
        "S0025 - SOUPS", Map(
            "C0150 - CANNED SOUP", ["F0841", "F0842", "F0845", "F0846"],
            "C0151 - AMBIENT CARTON SOUP", ["F0853"],
            "C0152 - INSTANT (CUP A SOUP) SOUP", ["F0856", "F0859", "F0860"],
            "C0153 - PACKET SOUP", ["F0867", "F0868", "F0869", "F0870"],
            "C0154 - AMBIENT POUCH SOUPS", ["F0871", "F0872", "F0873", "F0874", "F0876", "F0877"]
        ),
        "S0026 - SUGAR", Map(
            "C0155 - BROWN SUGARS", ["F0880", "F0881", "F0882", "F0883", "F0885"],
            "C0157 - CASTOR SUGARS", ["F0889", "F0890"],
            "C0159 - GRANULATED SUGARS", ["F0898", "F0899"],
            "C0160 - ICING SUGAR", ["F0901"],
            "C0161 - SUGAR SUBSTITUTES", ["F0904", "F0905", "F0906"]
        ),
        "S0233 - CONDIMENTS PACKET", Map(
            "C0834 - AMBIENT GRAVY & STOCK", ["F4264", "F4266", "F4267", "F4268", "F4269", "F4270"],
            "C0835 - AMBIENT HERBS & SPICES", ["F4279", "F4280", "F4281", "F4282"],
            "C0836 - AMBIENT STUFFING", ["F4285"],
            "C0837 - CROUTONS", ["F4287"],
            "C0838 - SALT AND PEPPER", ["F4292", "F4293"],
            "C0839 - DRY PACKETS SAUCES", ["F4295", "F4296", "F4297", "F4298"]
        ),
        "S0235 - HW NUTS/SEEDS/DRIED FRUITS", Map(
            "C0844 - HW NUTS/SEEDS/DRIED FRUIT", ["F4571", "F4572", "F4573"]
        ),
        "S0236 - HW BENEFIT FOODS", Map(
            "C0845 - HW POWDERS, SEEDS & TOPPERS", ["F4575"],
            "C0846 - HW HOT BEVERAGES", ["F4576", "F5233", "F5339"],
            "C0847 - HW AMBIENT SUGAR ALTERNATIVES", ["F4603"],
            "C0849 - HW PLANT BASED MEAL SOLUTIONS", ["F4578", "F5234", "F5235", "F5236"],
            "C0851 - HW NUT BUTTERS & SPREADS", ["F4580"]
        ),
        "S0246 - TAKE HOME AMBIENT JUICES", Map(
            "C0916 - AMBIENT JUICE", ["F5221", "F5222", "F5223", "F5224", "F5225", "F5226", "F5227", "F5228", "F5340"]
        ),
        "S0247 - HW SPORTS NUTRITION", Map(
            "C0920 - HW SPORTS NUTRITION FOOD & DRINK", ["F5238", "F5239", "F5240", "F5241", "F5341", "F5342"]
        ),
        "S0248 - HW VITAMINS & SUPPLEMENTS", Map(
            "C0921 - HW VITAMINS & SUPPLEMENTS", ["F5242", "F5243", "F5244", "F5245", "F5246", "F5247", "F5248"]
        ),
        "S1000002 - NON SCAN GROCERY EDIBLE", Map(
            "C1000002 - NON SCAN GROCERY EDIBLE", ["F1000002"]
        )
    ),
    "D0026 - GROCERY - NON FOOD", Map(
        "S0027 - PAPERWARE", Map(
            "C0165 - BULK JANITORIAL SYSTEMS", []
        ),
        "S0028 - PETFOOD CARE & TREATS", Map(
            "C0168 - PETCARE TREATS / CHEWS", ["F0931", "F0932", "F0933"],
            "C0169 - CAT FOOD WET", ["F0934", "F0935", "F0936", "F0937", "F3341", "F3522"],
            "C0170 - CAT FOOD DRY", ["F0938", "F0939"],
            "C0171 - CAT TREATS", ["F0940", "F0941"],
            "C0172 - OTHER PETFOOD", ["F0942", "F0943", "F0944"],
            "C0173 - PET ACCESSORIES", ["F0945", "F0946", "F0947", "F0948", "F0949"]
        ),
        "S0029 - LAUNDRY", Map(
            "C0174 - LAUNDRY POWDER", ["F0950", "F0951", "F0952", "F0953", "F0954", "F0955"],
            "C0175 - LAUNDRY LIQUID", ["F0956", "F0958", "F0960", "F0961"],
            "C0176 - LAUNDRY TABLETS", ["F0962", "F0964", "F0965", "F0966"],
            "C0177 - LAUNDRY LIQUID TABLET", ["F0967", "F0968", "F0969", "F0970"],
            "C0178 - FABRIC SOFTENER", ["F0971", "F0972", "F0973", "F0974", "F0975"],
            "C0179 - LAUNDRY AIDS & CLEANERS", ["F0976", "F0977", "F0978", "F0979", "F0980"]
        ),
        "S0030 - IGNITION & FIRESTARTERS", Map(
            "C0181 - IGNITION", ["F0985", "F0986", "F0987", "F0988", "F0989", "F0990"],
            "C0182 - MATCHES", ["F0991"]
        ),
        "S0031 - CLEANING", Map(
            "C0188 - WASHING UP LIQUID", ["F1015", "F1016", "F1017"],
            "C0189 - DISHWASHER", ["F1020", "F1021", "F1022", "F1023", "F1024", "F1025"],
            "C0191 - ALL PURPOSE CLEANERS", ["F1032", "F1033", "F1034", "F1035"],
            "C0192 - KITCHEN CLEANERS", ["F1036", "F1037", "F1038", "F1039"],
            "C0193 - TOILET CLEANERS", ["F1040", "F1041", "F1042", "F1043"],
            "C0194 - BATHROOM CLEANERS", ["F1044", "F1045", "F1046", "F1047"],
            "C0195 - DISINFECTANTS", ["F1049", "F1050", "F3238"],
            "C0196 - BLEACH", ["F1052", "F1053"],
            "C0198 - CARPET CLEANERS", ["F1059", "F1060", "F1061"],
            "C0199 - OVEN CLEANERS", ["F1062", "F1063"],
            "C0200 - FLOOR CLEANERS", ["F1066", "F1067", "F1068", "F1069"],
            "C0201 - AIR FRESHENERS", ["F1070", "F1071", "F1072", "F1073", "F1074", "F1075", "F1076", "F1077", "F1078"],
            "C0202 - FURNITURE CLEANERS & POLISHES", ["F1080", "F1081", "F1082", "F1083"],
            "C0203 - MISC. CLEANING", ["F1084", "F1085", "F1087"]
        ),
        "S0150 - TOILET & KITCHEN PAPER", Map(
            "C0725 - TOILET TISSUE", ["F3550", "F3551", "F3552"],
            "C0726 - KITCHEN TOWEL", ["F3554", "F3555", "F3556"]
        ),
        "S0151 - FACIAL TISSUE", Map(
            "C0727 - FACIAL TISSUE", ["F3557", "F3558", "F3559", "F3560", "F3561"]
        ),
        "S0240 - REFUSE SACKS/BIN LINERS", Map(
            "C0868 - REFUSE SACKS/BIN LINERS", ["F5004", "F5005", "F5006", "F5007"]
        ),
        "S0241 - FOOD WRAP", Map(
            "C0869 - FOIL, FILM, WRAP & BAGS", ["F5009", "F5010", "F5011", "F5012", "F5013", "F5015"]
        ),
        "S0242 - CLEANING CLOTHS,GLOVES & SHOES", Map(
            "C0870 - SHOE CARE", ["F5016", "F5017", "F5018"],
            "C0871 - GLOVES", ["F5022", "F5024"],
            "C0872 - CLOTHS & SCOURERS", ["F5027", "F5028"]
        ),
        "S0244 - ECO FRIENDLY RANGE", Map(
            "C0899 - ECO FRIENDLY HOME", ["F5157", "F5158", "F5159", "F5160"],
            "C0900 - ECO FRIENDLY OUT & ABOUT", ["F5161", "F5162"],
            "C0901 - ECO FRIENDLY BABY", ["F5163"],
            "C0902 - ECO FRIENDLY LIFESTYLE", ["F5164", "F5165", "F5166", "F5167", "F5168", "F5169"]
        ),
        "S1000003 - NON SCAN GROCERY NON FOOD", Map(
            "C1000003 - NON SCAN GROCERY NON FOOD", ["F1000003"]
        )
    ),
    "D0027 - BABY & KIDS", Map(
        "S0032 - BABY FOOD & DRINKS", Map(
            "C0205 - BABY FOOD STAGE 1 (4 MONTHS+)", ["F1091", "F1092", "F1093"],
            "C0206 - BABY FOOD STAGE 2 (7 MONTHS+)", ["F1094", "F1095", "F1096", "F5252"],
            "C0207 - BABY FOOD STAGE 3 (10 MONTHS+)", ["F1097", "F1098", "F1099"],
            "C0208 - BABY & KID SNACKS", ["F1100", "F1101", "F1102", "F1103"],
            "C0209 - BABY FOOD STAGE 4 (12 MONTHS+)", ["F1107"]
        ),
        "S0033 - BABY MILK", Map(
            "C0210 - BABY MILK STAGE 1 - FIRST MILK", ["F1108", "F1110"],
            "C0211 - BABY MILK STAGE 2 - FOLLOW ON MILK", ["F1111", "F1113"],
            "C0212 - BABY MILK STAGE 3 - GROWING UP MILK", ["F1114", "F1116"],
            "C0213 - BABY MILK STAGE 4 - GROWING UP MILK", ["F1117", "F1119"],
            "C0898 - BABY MILK SPECIALIST", ["F5154", "F5155"]
        ),
        "S0034 - BABY NAPPIES", Map(
            "C0214 - NAPPIES TAPED", ["F1120", "F1121", "F1122", "F1123", "F1124", "F1125"],
            "C0215 - NAPPIES PANTS", ["F1129", "F1130", "F1131"],
            "C0217 - NAPPIES  OTHERS", ["F1137", "F1138", "F1139"]
        ),
        "S0035 - BABY TOILETRIES & WIPES", Map(
            "C0218 - BABY HEALTHCARE", ["F1141", "F1143", "F1145", "F1147"],
            "C0219 - BABY TOILETRIES", ["F1150", "F1153", "F1154", "F1157"],
            "C0220 - BABY WIPES", ["F1158", "F1159"]
        ),
        "S0036 - BABY ACCESSORIES", Map(
            "C0221 - BABY NURSERY ACCESSORIES", ["F1162", "F1163", "F1164", "F1165", "F5207"],
            "C0222 - BABY FOOD ACCESSORIES", ["F1166", "F1167", "F1168"]
        ),
        "S0037 - BABY BASICS", Map(
            "C0223 - BABY CLOTHES", ["F1173", "F1174", "F1175", "F1176"],
            "C0224 - BABY  EQUIPMENT", ["F1180"]
        ),
        "S1000004 - NON SCAN BABY & KIDS", Map(
            "C1000004 - NON SCAN BABY & KIDS", ["F1000004"]
        )
    ),
    "D0028 - PERSONAL CARE", Map(
        "S0038 - MALE GROOMING", Map(
            "C0225 - MEN'S RAZORS AND BLADES", ["F1182", "F1183", "F1185"],
            "C0226 - MEN'S SHAVING", ["F1186", "F1187", "F1189"],
            "C0227 - MEN'S SKIN", ["F1190", "F1191", "F1192"],
            "C0228 - MEN'S PERSONAL WASH", ["F1193", "F1194"],
            "C0230 - MALE HAIR REMOVAL", [],
            "C0231 - MISC MALE", ["F1201"]
        ),
        "S0039 - HAIR", Map(
            "C0232 - HAIR SHAMPOO", ["F1202", "F1203", "F1204", "F1205", "F1206", "F1207"],
            "C0233 - HAIR CONDITIONER/ TREATMENTS", ["F1208", "F1209", "F1210", "F1211", "F1212", "F1213"],
            "C0234 - HAIR STYLING", ["F1214", "F1215", "F1216", "F1217", "F1218", "F1219", "F3295"],
            "C0235 - HAIR COLOUR", ["F1220", "F1221", "F1222"]
        ),
        "S0040 - PERSONAL WASH", Map(
            "C0236 - BATH WASH", ["F1223", "F1224", "F1225", "F1226", "F3297"],
            "C0237 - SHOWER WASH", ["F1227", "F1228", "F1229"],
            "C0238 - SOAP", ["F1230", "F1232", "F1233"]
        ),
        "S0041 - MEDICINAL", Map(
            "C0239 - MEDICINE - PAIN RELIEF", ["F1234", "F1235", "F1236", "F1237", "F4101"],
            "C0240 - FAMILY PLANNING", ["F1238", "F1239", "F1240", "F1241"],
            "C0241 - MEDICINE -  COLD & FLU", ["F1242", "F1243", "F1244", "F1245", "F1246", "F1247"],
            "C0242 - MEDICINE - STOMACH", ["F1248", "F1249", "F1250"],
            "C0243 - FIRST AID", ["F1251", "F1252", "F1253", "F1254"],
            "C0245 - MEDICINE - KIDS", ["F1258", "F1260"],
            "C0757 - STOP SMOKING", ["F4100"],
            "C0873 - FOOTCARE", ["F5031", "F5032", "F5033", "F5034", "F5040"]
        ),
        "S0042 - SANITARY PROTECTION", Map(
            "C0246 - SANITARY PADS", ["F1261", "F1262", "F1263", "F1264", "F1265", "F1266"],
            "C0247 - SANITARY TAMPONS", ["F1267", "F1268", "F1269"],
            "C0248 - SANITARY LINERS", ["F1270", "F1271"],
            "C0249 - INCONTINENCE PADS", ["F1272"]
        ),
        "S0043 - SKIN CARE", Map(
            "C0250 - SKINCARE- FACE", ["F1273", "F1274", "F1275", "F1276", "F1277", "F1278", "F3304"],
            "C0251 - SKINCARE - PROBLEM SKIN", ["F1279", "F1280", "F1281", "F1283"],
            "C0252 - SKINCARE- BODY", ["F1284", "F1285", "F1286"],
            "C0253 - SKINCARE- HAND", ["F1290", "F1291"],
            "C0254 - HAIR REMOVAL", ["F1292", "F1293", "F1294", "F1295"],
            "C0255 - COTTON WOOL", ["F1296", "F1297", "F1298", "F1299"],
            "C0256 - SELF TANNING", ["F1300", "F1301", "F1302", "F1303", "F3305"],
            "C0651 - LADY SHAVE PREP", ["F3310", "F3312"]
        ),
        "S0044 - ORAL CARE", Map(
            "C0258 - TOOTHPASTE", ["F1308", "F1309", "F1310", "F1311", "F1312", "F1313", "F1315"],
            "C0259 - TOOTHBRUSHES", ["F1316", "F1317", "F1318", "F1319", "F1320"],
            "C0260 - MOUTHWASH", ["F1321", "F1322"],
            "C0261 - DENTURE", ["F1323", "F1324", "F1325"],
            "C0262 - DENTAL ACC", ["F1326", "F1327", "F1328", "F1329", "F1330"]
        ),
        "S0045 - LADIES DEODORANTS", Map(
            "C0263 - FEMALE BODY SPRAYS", ["F1331", "F1332", "F1333"],
            "C0264 - FEMALE AEROSOLS", ["F1334", "F1335", "F1336"],
            "C0265 - FEMALE ROLL ONS", ["F1337", "F1338", "F1339"],
            "C0266 - FEMALE DEO STICKS", ["F1340", "F1341", "F1342"]
        ),
        "S0046 - SUN PREPS", Map(
            "C0267 - SUN PREP OILS & MILKS", ["F1343"],
            "C0268 - SUN PREP CREAMS & LOTIONS", ["F1344"],
            "C0269 - SUN PREP MOUSSE", ["F1345"],
            "C0270 - SUN PREP SPRAY", ["F1346"],
            "C0271 - SUN PREP STICKS", ["F1347"],
            "C0272 - SUN PREP WIPES", ["F1348"],
            "C0273 - AFTER SUN", ["F1349"],
            "C0274 - TAN ENHANCER", ["F1350"],
            "C0275 - INSECT REPELLENT", ["F1351"]
        ),
        "S0047 - PERSONAL CARE ACCESSORIES", Map(
            "C0276 - COSMETIC ACCESSORIES", ["F1352", "F1353", "F1354", "F1355", "F1356"],
            "C0277 - HAIR ACCESSORIES", ["F1357", "F1358", "F1359", "F1360", "F1361", "F1362", "F1363", "F3296"],
            "C0278 - BATH AIDS", ["F1364"],
            "C0279 - MANICURE", ["F1365", "F1366", "F1367", "F1368"]
        ),
        "S0048 - COSMETICS", Map(
            "C0280 - COSMETICS - LIPS", ["F1369", "F1370", "F1371"],
            "C0281 - COSMETICS - EYES", ["F1372", "F1373", "F1374"],
            "C0282 - COSMETICS - FOUNDATION", ["F1375", "F1376", "F1377"],
            "C0283 - COSMETICS - BLUSHER", ["F1378", "F1379", "F1380"],
            "C0284 - COSMETICS - CONCEALER", ["F1381"],
            "C0285 - COSMETICS - NAIL VARNISH", ["F1382"],
            "C0286 - COSMETICS - PERFUME", ["F1383"]
        ),
        "S0049 - SEASONAL PERSONAL CARE", Map(
            "C0287 - PERSONAL CARE SEASONAL", ["F1384"],
            "C0288 - PERSONAL CARE GIFTING", ["F1385"]
        ),
        "S0238 - HW BEAUTY ORGANIC & NATURAL", Map(
            "C0857 - HW MEN'S", ["F4590"],
            "C0858 - HW HAIR", ["F4591"],
            "C0859 - HW PERSONAL WASH", ["F4592"],
            "C0860 - HW SKIN CARE", ["F4593"],
            "C0861 - HW ORAL CARE", ["F4594"],
            "C0863 - HW SUN PREPS", ["F4596"],
            "C0864 - HW COSMETICS", ["F4597"],
            "C0865 - HW BABY", ["F4598"]
        ),
        "S1000005 - NON SCAN PERSONAL CARE", Map(
            "C1000005 - NON SCAN PERSONAL CARE", ["F1000005"]
        )
    ),
    "D0029 - BEERS/WINES/SPIRITS", Map(
        "S0050 - BEER & CIDER", Map(
            "C0289 - STOUT", ["F1386", "F1387", "F1388", "F1389", "F1390", "F3191", "F3195"],
            "C0290 - LAGER", ["F1391", "F1392", "F1393", "F1394", "F1395", "F1396", "F1397", "F3190", "F3194", "F5322",
                "F5323", "F5402"],
            "C0291 - ALE", ["F1398", "F1399", "F1400", "F1401", "F1402", "F3188", "F3192"],
            "C0292 - CIDER", ["F1403", "F1404", "F1406", "F5324", "F5325", "F5326", "F5327", "F5328", "F5417", "F5418"],
            "C0884 - PREMIXED SPIRITS", ["F5085", "F5086", "F5087", "F5088", "F5089", "F5117", "F5329", "F5330",
                "F5331", "F5419"]
        ),
        "S0051 - WINE", Map(
            "C0294 - RED WINE", ["F1412", "F1413", "F1414", "F1415", "F1416", "F1417", "F1418", "F1419", "F1420",
                "F1421", "F1422", "F1423", "F1424", "F1425", "F1426", "F1427", "F1428", "F1429"],
            "C0295 - WHITE WINE", ["F1430", "F1431", "F1432", "F1433", "F1434", "F1435", "F1436", "F1437", "F1438",
                "F1439", "F1440", "F1441", "F1442", "F1443", "F1444", "F1445", "F1446", "F1447"],
            "C0296 - ROSE", ["F1448", "F1449", "F1450", "F1451", "F1452", "F1453", "F1454", "F1455", "F1456", "F1457",
                "F1458", "F1459", "F1460", "F5003"],
            "C0297 - SPARKLING WINE", ["F1461", "F1462", "F1463", "F1464", "F1465", "F1466", "F1467", "F1468", "F1469",
                "F1470", "F1471", "F1472", "F1473"],
            "C0298 - CHAMPAGNE", ["F1474", "F1475", "F1476", "F1477", "F1478"],
            "C0299 - WINE BOX", ["F1479", "F1480", "F1481"],
            "C0300 - WINE BOTTLES <75CL", ["F1482", "F1483", "F1484", "F1485"],
            "C0301 - GIFTING WINE", ["F1486", "F1487", "F1488", "F1489", "F5209"]
        ),
        "S0052 - FORTIFIED WINE", Map(
            "C0302 - SHERRY", ["F1490", "F1491", "F1492"],
            "C0303 - PORT", ["F1493", "F1494", "F1495", "F1496"],
            "C0304 - VERMOUTH", ["F1497", "F1498", "F1499"],
            "C0305 - BRITISH FORTIFIED WINE", ["F1500"],
            "C0306 - OTHER FORTIFIED WINE", ["F1501", "F1502", "F1503"]
        ),
        "S0053 - SPIRITS & LIQUEURS", Map(
            "C0307 - AMERICAN WHISKEY", ["F1504", "F1505", "F1506", "F1507"],
            "C0308 - IRISH WHISKEY", ["F1508", "F1509", "F1510", "F1511", "F5109"],
            "C0309 - SCOTCH WHISKY", ["F1512", "F1513", "F1514", "F1515", "F5111"],
            "C0310 - TEQUILA", ["F1516"],
            "C0311 - VODKA", ["F1517", "F1518", "F1519", "F1520", "F5112"],
            "C0312 - TEQUILA", ["F1521", "F1522"],
            "C0313 - BRANDY", ["F1523", "F1524", "F1525", "F1526", "F1527", "F5107"],
            "C0314 - CREAM LIQUEURS", ["F1528", "F1529", "F1530", "F1531"],
            "C0315 - GIN", ["F1532", "F1533", "F1534", "F1535", "F5108"],
            "C0316 - LIQUEURS", ["F1536", "F1537", "F1538"],
            "C0317 - OTHER SPIRITS", ["F1539", "F1540", "F3196"],
            "C0319 - RUM", ["F1544", "F1545", "F1546", "F1547", "F1548", "F1549", "F5110", "F5332"]
        ),
        "S0234 - CRAFT WORLD BEER", Map(
            "C0840 - CRAFT LAGER", ["F4530", "F4532", "F4533", "F4541", "F4542"],
            "C0841 - CRAFT STOUT", ["F4543", "F4544", "F4545", "F4546", "F4547"],
            "C0842 - CRAFT ALE", ["F4548", "F4550", "F4551", "F4557", "F4558"],
            "C0843 - CRAFT CIDER", ["F4559", "F4561", "F4562", "F4568", "F4569"]
        ),
        "S0245 - NON ALCOHOLIC", Map(
            "C0907 - NON-ALC BEER & CIDER", ["F5182", "F5183", "F5184", "F5185", "F5333", "F5401"],
            "C0908 - NON-ALC SPIRITS & LIQUERS", ["F5187", "F5188", "F5189", "F5190", "F5191", "F5334"],
            "C0909 - NON-ALC CRAFT WORLD BEER", ["F5192", "F5193", "F5194", "F5335", "F5336", "F5337"],
            "C0910 - NON-ALC WINE", ["F5195", "F5196", "F5197", "F5198"]
        ),
        "S1000006 - NON SCAN BEERS / WINES / SPIRITS", Map(
            "C1000006 - NON SCAN BEERS / WINES / SPIRITS", ["F1000006"]
        )
    ),
    "D0033 - MEAT, POULTRY & FISH", Map(
        "S0075 - FISH SERVEOVER", Map(
            "C0374 - FISH SERVE OVER", ["F1868", "F1869", "F1870", "F1871", "F1872", "F1873", "F1874", "F1875", "F1876",
                "F3827", "F5321"]
        ),
        "S0076 - READY TO COOK MPF", Map(
            "C0376 - BEEF READY TO COOK", ["F1906", "F1907", "F1908", "F1909"],
            "C0377 - LAMB READY TO COOK", ["F1910", "F1911", "F1912", "F1913"],
            "C0378 - PORK READY TO COOK", ["F1914", "F1915", "F1916", "F1917"],
            "C0379 - CHICKEN READY TO COOK", ["F1918", "F1919", "F1920", "F1921"],
            "C0380 - TURKEY READY TO COOK", ["F1922", "F1923", "F1924", "F1925"],
            "C0381 - DUCK READY TO COOK", ["F1926", "F1927", "F1928", "F1929"],
            "C0382 - BACON READY TO COOK", ["F1930", "F1931", "F1932", "F1933"],
            "C0383 - FISH READY TO COOK", ["F1934", "F1935", "F1936", "F1937"]
        ),
        "S0077 - READY TO SERVE MPF", Map(
            "C0384 - BEEF READY TO SERVE", ["F1938", "F1939", "F1940", "F1941", "F1942"],
            "C0385 - LAMB READY TO SERVE", ["F1943", "F1944", "F1945", "F1946", "F1947"],
            "C0386 - PORK READY TO SERVE", ["F1948", "F1949", "F1950", "F1951", "F1952"],
            "C0387 - CHICKEN READY TO SERVE", ["F1953", "F1954", "F1955", "F1956", "F1957"],
            "C0388 - TURKEY READY TO SERVE", ["F1958", "F1959", "F1960", "F1961", "F1962"],
            "C0389 - DUCK READY TO SERVE", ["F1963", "F1964", "F1965", "F1966", "F1967"],
            "C0390 - BACON READY TO SERVE", ["F1968", "F1969", "F1970", "F1971", "F1972"]
        ),
        "S0078 - LOOSE SAUSAGES, BACON & PUDDINGS", Map(
            "C0391 - LOOSE RASHERS (BACON)", ["F1973"],
            "C0392 - LOOSE PUDDING", ["F1974"],
            "C0393 - LOOSE SAUSAGES", ["F1975"]
        ),
        "S0155 - MEAT & POULTRY SERVEOVER", Map(
            "C0738 - BEEF SERVEOVER", ["F3609", "F3610", "F3611", "F3612", "F3613", "F3614", "F3615", "F3616", "F3617",
                "F3618", "F3619"],
            "C0739 - LAMB SERVEOVER", ["F3620", "F3621", "F3622", "F3623", "F3624", "F3625", "F3626", "F3627", "F3628"],
            "C0740 - PORK SERVEOVER", ["F3629", "F3630", "F3631", "F3632", "F3633", "F3634", "F3635", "F3636", "F3637"],
            "C0741 - BACON JOINTS SERVEOVER", ["F3638", "F3639", "F3640", "F3641", "F3642", "F3643", "F3644", "F4256"],
            "C0742 - CHICKEN SERVEOVER", ["F3645", "F3646", "F3647", "F3648", "F3649", "F3650", "F3651", "F3652"],
            "C0743 - TURKEY SERVEOVER", ["F3653", "F3654", "F3655", "F3656", "F3657", "F3658", "F3659", "F3660",
                "F3661", "F3662", "F3663", "F3664"],
            "C0744 - BRD POULTRY SERVEOVER", ["F3665", "F3666", "F3667", "F3668", "F3669", "F3670", "F3671", "F3672",
                "F3673"],
            "C0745 - GAME SERVEOVER", ["F3674", "F3675", "F3676", "F3677", "F3678", "F3679", "F3680"],
            "C0746 - FRESHLY PREPARED BY INGREDIENTS", ["F3681", "F5253"]
        ),
        "S0156 - MEAT & POULTRY PREPACK", Map(
            "C0747 - BEEF PREPACK", ["F3682", "F3683", "F3684", "F3685", "F3686", "F3687", "F3688", "F3689", "F3690",
                "F3691", "F3692", "F3693", "F3694", "F3695", "F3696", "F3697", "F3698", "F3699", "F3700", "F3701",
                "F3702"],
            "C0748 - LAMB PREPACK", ["F3703", "F3704", "F3705", "F3706", "F3707", "F3708", "F3709", "F3710", "F3711",
                "F3712", "F3713", "F3714", "F3715", "F3716", "F3717", "F3718", "F3719"],
            "C0749 - PORK PREPACK", ["F3720", "F3721", "F3722", "F3723", "F3724", "F3725", "F3726", "F3727", "F3728",
                "F3729", "F3730", "F3731", "F3732", "F3733", "F3734", "F3735", "F5396"],
            "C0750 - BACON JOINTS PREPACK", ["F3736", "F3737", "F3738", "F3739", "F3740", "F3741", "F3742", "F3743",
                "F3744", "F3745", "F3746", "F3747", "F3748"],
            "C0751 - CHICKEN PREPACK", ["F3749", "F3750", "F3751", "F3752", "F3753", "F3754", "F3755", "F3756", "F3757",
                "F3758", "F3759", "F3760", "F3761", "F3762", "F3763", "F3764", "F3765", "F3766", "F3767", "F3768"],
            "C0752 - TURKEY PREPACK", ["F3769", "F3770", "F3771", "F3772", "F3773", "F3774", "F3775", "F3776", "F3777",
                "F3778", "F3779", "F3780", "F3781", "F3782", "F3783", "F3784", "F3785", "F3786", "F3787", "F3788",
                "F3789", "F3790", "F3791"],
            "C0753 - BRD POULTRY PREPACK", ["F3792", "F3793", "F3794", "F3795", "F3796", "F3797", "F3798", "F3799",
                "F3800", "F3801", "F3802", "F3803", "F3804"],
            "C0754 - GAME PREPACK", ["F3805", "F3806", "F3807", "F3808", "F3809", "F3810", "F3811", "F3812", "F3813",
                "F3814", "F3815", "F3816"],
            "C0938 - MEAT ACCOMPANIMENTS", ["F5393"]
        ),
        "S0157 - FISH PREPACK", Map(
            "C0755 - FISH PREPACK", ["F3828", "F3829", "F3830", "F3831", "F3832", "F3833", "F3834", "F3835", "F3836",
                "F3837", "F3838", "F3839", "F3840", "F3841", "F3842", "F3843", "F3844", "F3845", "F3846", "F3847",
                "F3848", "F3849", "F3850", "F3851", "F3852", "F3853", "F3854", "F3855", "F3856"],
            "C0756 - FISH READY TO EAT PREPACK", ["F3857", "F3858", "F3859", "F3860", "F3861", "F3862", "F3863",
                "F3864", "F3865"]
        ),
        "S1000009 - NON SCAN IMPULSE MEAT / POULTRY / FISH", Map(
            "C1000009 - NON SCAN IMPULSE MEAT / POULTRY / FISH", ["F1000009"]
        ),
        "S1000020 - GENERIC ART- FRESH MEAT EST.MARGIN", Map(
            "C1000020 - GENERIC ART- FRESH MEAT EST.MARGIN", ["F1000020"]
        )
    ),
    "D0034 - DAIRY", Map(
        "S0080 - YOGURTS & DESSERTS", Map(
            "C0395 - EVERYDAY YOGURTS", ["F1980", "F1981", "F1982", "F1983"],
            "C0396 - PREMIUM YOGURTS", ["F1984", "F1985", "F1986"],
            "C0397 - NATURAL YOGURTS", ["F1987", "F1988", "F1989", "F1990"],
            "C0398 - FUNCTIONAL YOGURTS & DRINKS (ACTIVE HEALTH)", ["F1991", "F1992", "F1993", "F1994", "F1995"],
            "C0399 - DAIRY FREE YOGURTS", ["F1996", "F1997", "F1998", "F1999", "F2000"],
            "C0400 - LOW FAT YOGURTS", ["F2001", "F2002", "F2003", "F2004"],
            "C0401 - ORGANIC YOGURTS", ["F2005", "F2006", "F2007", "F2008", "F2009"],
            "C0402 - YOGURT DRINKS", ["F2010", "F2011", "F2012", "F2013", "F2014"],
            "C0403 - ADULT CHILLED  DESSERTS", ["F2015", "F2016", "F2017", "F2018", "F2019", "F2020", "F2021", "F2022",
                "F2023", "F2024", "F2025", "F2026"],
            "C0404 - PROTEIN", ["F2030", "F5391"],
            "C0405 - KIDS YOGURTS & DESSERTS", ["F2033", "F2034", "F2035", "F2036", "F2037", "F2038", "F2039"]
        ),
        "S0081 - MILK & CREAM", Map(
            "C0406 - COWS MILK", ["F2040", "F2041", "F2042", "F2043", "F2044", "F2045", "F2046"],
            "C0407 - SPECIALITY MILK", ["F2047", "F2048", "F2049", "F2050", "F2051", "F3203", "F5348", "F5381", "F5382"],
            "C0408 - FLAVOURED MILK & DRINKS", ["F2052"],
            "C0409 - CREAM", ["F2054", "F2055", "F2056", "F2057", "F2058", "F2059", "F2060", "F2061", "F2062", "F2063",
                "F2064", "F2065", "F2066", "F5398"]
        ),
        "S0082 - BUTTERS AND SPREADS", Map(
            "C0410 - BUTTER", ["F2067", "F2068", "F2069", "F2070", "F2071"],
            "C0411 - DAIRY SPREADS", ["F2072", "F2073"],
            "C0412 - HEALTH SPREADS", ["F2074", "F2075", "F2076", "F2077"],
            "C0413 - FUNCTIONAL BUTTER/SPREADS", ["F2078", "F2079", "F2080", "F2081", "F2082"],
            "C0414 - COOKING BUTTERS/SPREADS", ["F2083", "F2084", "F2085"],
            "C0415 - PASTRY BUTTERS/SPREADS", ["F2086", "F2087", "F2088", "F2089"],
            "C0416 - MINI BUTTER/SPREAD PACKS", ["F2090", "F2091", "F2092", "F2093"]
        ),
        "S0083 - PREPACK CHEESE", Map(
            "C0417 - RED CHEDDAR BLOCK", ["F2094", "F2095", "F2096", "F2097", "F2098"],
            "C0418 - WHITE CHEDDAR BLOCK", ["F2099", "F2100", "F2101", "F2102", "F2103"],
            "C0419 - NATURAL CONVENIENCE CHSE", ["F2104", "F2105"],
            "C0420 - PROCESSED CONVENIENCE CHS", ["F2106", "F2107", "F2108"],
            "C0421 - CHEESE SNACKS", ["F2109", "F2110", "F2111", "F2112"],
            "C0425 - PROCESSED SOFT WHITE CHSE", ["F2133", "F2134", "F2135", "F2136"],
            "C0427 - DAIRY & LACTOSE FREE", ["F2144", "F2145"]
        ),
        "S0084 - TAKE HOME CHILLED JUICE", Map(
            "C0430 - NOT FROM C/CENTRATE JUICE", ["F2148", "F2149", "F2150", "F2151", "F2152", "F2153", "F5343",
                "F5344", "F5345"],
            "C0431 - FROM CONCENTRATE JUICE", ["F2154", "F2155", "F2156", "F2157", "F2158", "F2159", "F2160"],
            "C0432 - FRESHLY SQUEEZED JUICE", ["F2161", "F2162", "F2163", "F2164", "F2165", "F5346"],
            "C0433 - SMOOTHIES", ["F2166", "F2167", "F2168", "F2169"],
            "C0434 - JUICE DRINKS", ["F2170", "F2171", "F2172", "F2173", "F5347"]
        ),
        "S0085 - EGGS", Map(
            "C0435 - INTENSIVE COMMERCIAL EGGS", ["F2174", "F2175", "F2176", "F2177", "F2178", "F2179", "F2180"],
            "C0436 - BARN FARMED EGGS", ["F2181", "F2182", "F2183", "F2184", "F2185", "F2186", "F2187"],
            "C0437 - FREE RANGE EGGS", ["F2188", "F2189", "F2190", "F2191", "F2192", "F2193", "F2194"],
            "C0438 - ORGANIC EGGS", ["F2195", "F2196", "F2197", "F2198", "F2199", "F2200", "F2201"],
            "C0439 - SPECIALITY EGGS", ["F2202", "F2203", "F2204", "F2205", "F2206", "F2207", "F2208", "F5270"]
        ),
        "S0153 - PP SPECIALITY CHEESE", Map(
            "C0730 - HARD SPECIALITY CHEESE", ["F3579", "F3580", "F3581", "F3582", "F3583", "F3584", "F3585"],
            "C0731 - BLUE SPECIALITY CHEESE", ["F3586", "F3587", "F3588", "F3589", "F3590", "F3591", "F3592"],
            "C0732 - WHITE SPECIALITY CHEESE", ["F3593", "F3594", "F3595", "F3596", "F3597", "F3598", "F3599"],
            "C0733 - CUISINE CHEESE", ["F3600", "F3601", "F3602", "F3603", "F3604", "F3605", "F3606"],
            "C0734 - REGIONAL CHEESES", ["F3607"],
            "C0735 - SEASONAL CHEESES", ["F3608"]
        ),
        "S1000010 - NON SCAN DAIRY", Map(
            "C1000010 - NON SCAN DAIRY", ["F1000010"]
        )
    ),
    "D0035 - BREAD AND CAKES", Map(
        "S0228 - WRAPPED BREAD", Map(
            "C0813 - STANDARD WHITE BREAD", ["F4115", "F4117", "F4120", "F5249"],
            "C0875 - STANDARD BROWN BREAD", ["F5054", "F5055", "F5250"],
            "C0876 - LIFESTYLE BREAD", ["F5057", "F5060"],
            "C0877 - SODA BREAD", ["F5062"],
            "C0878 - SANDWICH CARRIERS", ["F5064", "F5065", "F5066"],
            "C0879 - MORNING GOODS", ["F5067", "F5068"]
        ),
        "S0229 - PACKAGED CAKE", Map(
            "C0814 - SMALL CAKES,TREATS", ["F4121", "F4122", "F4123", "F4124", "F4125", "F4126", "F4127", "F5069",
                "F5070", "F5071", "F5072"],
            "C0880 - FAMILY CAKES, TREATS", ["F5073", "F5074", "F5075", "F5076", "F5077"],
            "C0881 - FINISH AT HOME", ["F5078", "F5079"],
            "C0882 - OCCASIONAL CAKES", ["F5080"],
            "C0883 - SEASONAL", ["F5081", "F5082", "F5083", "F5084"]
        ),
        "S0231 - FRESH BAKERY", Map(
            "C0816 - ROLLS & BAGUETTES", ["F4131", "F4132", "F4133"],
            "C0818 - SHARING TREATS", ["F4139", "F4140", "F4141", "F5124", "F5125", "F5358", "F5359", "F5360"],
            "C0819 - LOAVES", ["F4142", "F4143", "F4144", "F4145", "F5126", "F5364", "F5365", "F5366", "F5367", "F5368"],
            "C0820 - SINGLE TREATS", ["F4146", "F4147", "F4148", "F4149", "F5127", "F5128", "F5361", "F5362", "F5363"],
            "C0821 - CHILLED TREATS", ["F4150", "F4151", "F4152"]
        ),
        "S0232 - SCRATCH BAKERY", Map(
            "C0823 - SCRATCH CHILLED TREATS", ["F4157", "F4158"],
            "C0824 - SCRATCH SHARING TREATS", ["F4160", "F4161", "F4162", "F4163", "F5133", "F5369", "F5370", "F5371",
                "F5372", "F5373", "F5374"],
            "C0825 - SCRATCH INGREDIENTS", ["F4164", "F4165", "F4166", "F4167"],
            "C0893 - SCRATCH ROLLS & BAGUETTES", ["F5134", "F5135", "F5136"],
            "C0896 - SCRATCH SINGLE TREATS", ["F5142", "F5143", "F5144", "F5145", "F5146", "F5147"],
            "C0897 - SCRATCH LOAVES", ["F5148", "F5149", "F5150", "F5151", "F5152", "F5375", "F5376", "F5377", "F5378",
                "F5379"]
        ),
        "S1000011 - NON SCAN BREAD & CAKES", Map(
            "C1000011 - NON SCAN BREAD & CAKES", ["F1000011"]
        )
    ),
    "D0037 - PROVISIONS & CONVENIENCE", Map(
        "S0102 - PREPACK COOKED MEATS", Map(
            "C0497 - PP WAFERTHIN COOKED MEATS", ["F2467", "F2468", "F2469", "F2470"],
            "C0498 - PP STANDARD COOKED MEATS", ["F2471", "F2472", "F2473", "F2474", "F2475"],
            "C0499 - PP PREMIUM COOKED MEATS", ["F2476", "F2477", "F2478", "F2479"],
            "C0500 - PP SUPERPREMIUM COOKED MEATS", ["F2480", "F2481", "F2482", "F2483"],
            "C0502 - PP COOKED MEAT PIECES", ["F2488", "F2489", "F2490"],
            "C0505 - CKD POULTRY", ["F2502", "F2503", "F2504", "F2505", "F2506"]
        ),
        "S0103 - CHILLED  READY MEALS", Map(
            "C0506 - HEALTHY EATING  READY MEALS", ["F2507", "F2508", "F2509", "F2510", "F2511", "F2512", "F2513",
                "F2514", "F2515", "F2516", "F2517", "F2518", "F2519", "F2520", "F2521", "F2522", "F2523", "F2524",
                "F5380"],
            "C0507 - STANDARD READY MEALS", ["F2525", "F2526", "F2527", "F2528", "F2529", "F2530", "F2531", "F2532",
                "F2533"],
            "C0508 - PREMIUM READY MEALS", ["F2535", "F2536", "F2537", "F2538", "F2539", "F2540", "F2541", "F2542"],
            "C0932 - KITCHEN MEALS", ["F5349"]
        ),
        "S0104 - CHILLED PIZZA, PASTA & SAUCES", Map(
            "C0509 - CHILLED PASTA", ["F2543", "F2544", "F2545", "F2546", "F3337"],
            "C0510 - CHILLED SAUCES", ["F2547", "F2548", "F2549", "F2550", "F2551", "F2552"],
            "C0511 - CHILLED BREADS", ["F2553", "F2554", "F2555", "F2556", "F2557"],
            "C0512 - CHILLED PIZZA", ["F2564", "F2565", "F2566", "F2567", "F2568", "F2569", "F2570", "F2571"]
        ),
        "S0105 - CHILLED CONVENIENCE FOODS", Map(
            "C0513 - CHILLED SOUPS", ["F2572", "F2573", "F2574", "F2575", "F2576", "F2577", "F5389"],
            "C0514 - CHILLED PREPACK SALADS", ["F2578", "F2579", "F2580", "F2581", "F2582", "F2583", "F2584", "F2585"],
            "C0515 - CHILLED PASTRIES & SAVOURIES", ["F2586", "F2587", "F2588", "F2589", "F2590", "F2591", "F2592",
                "F2593"],
            "C0516 - CHILLED SNACKING", ["F2594", "F2595", "F2596", "F3338"],
            "C0517 - CHILLED VEGETARIAN FOODS", ["F2597", "F2598", "F2599"],
            "C0519 - CHILLED PARTY FOODS", ["F2605"],
            "C0520 - SEASONAL CONVENIENCE FOODS", ["F2606"],
            "C0521 - TRADITIONAL MEAL ACCOMPANIMENTS", ["F2558", "F2559", "F2560", "F2561", "F2562", "F2563", "F2607",
                "F3339"],
            "C0654 - ORIENTAL MEAL  ACCOMPANIMENTS", ["F3322", "F3323", "F3324", "F3325", "F3326"]
        ),
        "S0106 - PREPACK PUDDING", Map(
            "C0522 - EVERYDAY PUDDING", ["F2608", "F2609"],
            "C0523 - PREMIUM PUDDING", ["F2610", "F2611"],
            "C0524 - HEALTHY PUDDING", ["F2612", "F2614"],
            "C0652 - MIXED PUDDING", ["F3315", "F3316"]
        ),
        "S0107 - PREPACK RASHERS", Map(
            "C0525 - EVERYDAY RASHERS", ["F2615", "F2616", "F2617", "F2619"],
            "C0526 - PREMIUM RASHERS", ["F2623", "F2624", "F5383"],
            "C0527 - HEALTHY RASHERS", ["F2625", "F2626", "F2627", "F3319"]
        ),
        "S0108 - PREPACK SAUSAGES", Map(
            "C0528 - EVERYDAY SAUSAGES", ["F2630", "F2631", "F2632", "F2634", "F2635"],
            "C0529 - PREMIUM SAUSAGES", ["F2637", "F2638", "F2639", "F2640"],
            "C0530 - HEALTHY SAUSAGES", ["F2644", "F2645", "F2646", "F2647"]
        ),
        "S0109 - STUFFING AND BREADCRUMBS", Map(
            "C0531 - PP STUFFING & BREADCRUMBS", ["F2648", "F3321"]
        ),
        "S0110 - KOSHER", Map(
            "C0532 - KOSHER", ["F2649", "F2650", "F2651", "F2652", "F2653", "F2654", "F2655"]
        ),
        "S0152 - PP SPECIALITY CONVENIENCE FOODS", Map(
            "C0728 - PP PATE", ["F3573", "F3574"],
            "C0729 - PP OLIVES & TAPENADES", ["F3575", "F3576", "F3577"],
            "C0912 - CHILLED DIPS", ["F5210", "F5211", "F5212"]
        ),
        "S0154 - PP SPECIALITY COOKED MEATS", Map(
            "C0736 - PP CONTINENTAL COOKED MEATS", ["F3562", "F3563", "F3564", "F3565", "F3566"],
            "C0737 - PP COOKED SAUSAGE", ["F3567", "F3568", "F3569", "F3570"]
        ),
        "S1000013 - NON SCAN PROVISIONS & CONVENIENCE", Map(
            "C1000013 - NON SCAN PROVISIONS & CONVENIENCE", ["F1000013"]
        )
    ),
    "D0038 - FROZEN FOODS", Map(
        "S0112 - IMPULSE ICE CREAM", Map(
            "C0534 - INDULGENT ICE CREAM", ["F2662", "F2663", "F2664"],
            "C0535 - CHILDRENS  ICE CREAM", ["F2665", "F2666", "F2667"],
            "C0536 - I/CRM FRUIT REFRESHMENT", ["F2668", "F2669", "F2670"],
            "C0537 - SOFT SERVE ICE CREAM CONES", ["F2671", "F5106"],
            "C0538 - SOFT ICE CREAM", ["F2672", "F2673"],
            "C0831 - PREPACK IMPULSE ICE CREAM", ["F4258"]
        ),
        "S0113 - TAKE HOME ICE CREAM", Map(
            "C0539 - HEALTH & DIETARY ICE CREAM", ["F2674", "F2675"],
            "C0540 - LUXURY ICE CREAM & FROZEN DESSERTS", ["F2684", "F2685", "F2686"],
            "C0541 - ICE CREAM TUBS", ["F2690", "F5254"],
            "C0922 - ICE CREAM TUBS - VALUE", ["F5255", "F5256"],
            "C0923 - ICE CREAM SNACKING", ["F5257"],
            "C0924 - ICE CREAM MULTIPACK STICKS", ["F5258", "F5259"],
            "C0925 - ICE CREAM MULTIPACK STICKS VALUE", ["F5260", "F5261"]
        ),
        "S0114 - TAKE HOME FRUIT & ICE", Map(
            "C0543 - FRUIT", ["F2707"],
            "C0545 - ICE", ["F2713", "F5262"]
        ),
        "S0115 - FROZEN PIZZA", Map(
            "C0546 - FROZEN WHOLE PIZZA", ["F2715", "F2716", "F2717", "F2718", "F3524"],
            "C0547 - FROZEN SINGLE SERVE PIZZA", ["F2719", "F2720"]
        ),
        "S0116 - FROZEN READY MEALS", Map(
            "C0548 - HEALTHIER FROZEN READY MEALS", ["F2721", "F2722", "F2723", "F2724", "F2725", "F2726", "F2727",
                "F2728", "F2729", "F2730", "F2731", "F2732", "F2733", "F2734", "F2735", "F3223"],
            "C0549 - STANDARD FROZEN READY MEALS", ["F2736", "F2737", "F2738", "F2739", "F2740", "F2741", "F3224"],
            "C0550 - PREMIUM FROZEN READY MEALS", ["F2742", "F2743", "F2744", "F2745", "F2746", "F2747", "F3225"],
            "C0551 - STEAMED FROZEN READY MEALS", ["F2748", "F2749", "F2750", "F2751", "F2752", "F2753", "F3226"],
            "C0552 - KIDS FROZEN READY MEALS", ["F2754"]
        ),
        "S0117 - FROZEN BAKERY", Map(
            "C0553 - FROZEN GARLIC BREAD", ["F2755", "F2756", "F2757", "F2758"],
            "C0554 - FROZEN BREAD", ["F2759", "F2760"]
        ),
        "S0118 - FROZEN PASTRIES & SAVOURIES", Map(
            "C0555 - FRZN SPRING ROLLS & ACCOM", ["F2761", "F2762", "F2763", "F2764", "F2765", "F2766", "F2767",
                "F2768", "F2769", "F2770", "F2771", "F2772", "F2773", "F2774", "F2775", "F2776", "F2777", "F2778",
                "F2779", "F3227"],
            "C0556 - FROZEN PIES", ["F2780", "F2781", "F2782"],
            "C0557 - FROZEN QUICHE", ["F2783", "F2784", "F2785"],
            "C0558 - FROZEN SAUSAGE ROLLS", ["F2786", "F2787"],
            "C0559 - FROZEN PANCAKES", ["F2788", "F2789", "F2790"],
            "C0560 - FROZEN BAKING PASTRY", ["F2791", "F2792", "F2793", "F2794"],
            "C0561 - FROZEN YORKSHIRE PUDDINGS", ["F2795", "F2796"],
            "C0562 - FROZEN SEASONAL PASTRY", ["F2797"]
        ),
        "S0119 - FROZEN FISH", Map(
            "C0563 - FROZEN COATED FISH", ["F2798", "F2799", "F2800", "F2801", "F2802"],
            "C0564 - FROZEN NATURAL FISH", ["F2803", "F2804", "F2805", "F2806", "F2807"],
            "C0565 - FROZEN FISH FINGERS", ["F2808", "F2809", "F2810"],
            "C0566 - FROZEN SPECIALITY FISH", ["F2811", "F2812", "F2813"],
            "C0567 - FROZEN FISH MEALS", ["F2814", "F2815"],
            "C0568 - FROZEN FISH IN SAUCE", ["F2816", "F2817"]
        ),
        "S0120 - FROZEN BUTCHERY", Map(
            "C0569 - FROZEN POULTRY", ["F2818", "F2819", "F2820", "F2821"],
            "C0570 - FROZEN LAMB", ["F2822", "F2823", "F2824", "F2825"],
            "C0571 - FROZEN PORK", ["F2826", "F2827", "F2828", "F2829"],
            "C0572 - FROZEN BEEF", ["F2830", "F2831", "F2832", "F2833"],
            "C0573 - FROZEN SAUSAGE MEAT", ["F2834"],
            "C0574 - OTHER FROZEN MEAT", ["F2835"],
            "C0575 - FROZEN SEASONAL MEAT", ["F2836"]
        ),
        "S0121 - FROZEN POULTRY PRODUCTS", Map(
            "C0576 - FROZEN ADULT POULTRY", ["F2837", "F2838", "F2839", "F2840"],
            "C0577 - FROZEN KIDS POULTRY", ["F2841", "F2842", "F2843", "F2844"]
        ),
        "S0122 - FROZEN BURGERS GRILLS & SAUSAGES", Map(
            "C0578 - FROZEN BURGERS", ["F2845", "F2846", "F2847", "F2848", "F2849"],
            "C0579 - FROZEN SAUSAGES", ["F2850", "F2851"],
            "C0580 - FROZEN GRILLS & STEAKS", ["F2852", "F2853"]
        ),
        "S0123 - FROZEN VEGETARIAN FOODS", Map(
            "C0581 - FROZEN READY MEALS", ["F2854", "F2855", "F2856", "F2857", "F2858", "F2859", "F2860"],
            "C0582 - FROZEN MEAT SUBSTITUTES", ["F2861", "F2862", "F2863", "F2864"]
        ),
        "S0124 - FROZEN VEGETABLES", Map(
            "C0583 - FROZEN PEAS", ["F2865", "F2866", "F2867", "F2868", "F2869"],
            "C0584 - OTHER FROZEN VEG", ["F2870", "F2871", "F2872", "F2873", "F2874", "F2875", "F2876", "F2877",
                "F2878", "F2879", "F2880", "F2881", "F2882", "F2883", "F3222", "F3512"],
            "C0585 - FROZEN MIXED VEGETABLES", ["F2884", "F2885", "F2886", "F2887"],
            "C0586 - FROZEN RICE", ["F2888", "F2889"]
        ),
        "S0125 - FROZEN POTATO", Map(
            "C0587 - FROZEN CHIPS", ["F2890", "F2891", "F2892", "F2893"],
            "C0588 - FROZEN POTATO PRODUCTS", ["F2903", "F2904", "F2905", "F2906", "F2907", "F2908", "F2909", "F2910",
                "F2911"]
        ),
        "S1000014 - NON SCAN FROZEN", Map(
            "C1000014 - NON SCAN FROZEN", ["F1000014"]
        )
    )
)