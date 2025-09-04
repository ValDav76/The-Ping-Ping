    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;


    entity disto_core is
        generic(
            G_WITDH : integer := 16;
            G_LUT_DEPTH : integer := 256 -- must be a power of two !
        );
        port(
            s_axi_s_tdata   : in  std_logic_vector(G_WITDH-1 downto 0);
            s_axi_s_tvalid  : in  std_logic;
            s_axi_s_tready  : out std_logic;

            m_axi_s_tdata   : out std_logic_vector(G_WITDH-1 downto 0);
            m_axi_s_tvalid  : out std_logic;
            m_axi_s_tready  : in  std_logic;

            clk             : in  std_logic;
            rst             : in std_logic
        );
    end disto_core;

    architecture rtl of disto_core is
        signal data : std_logic_vector(G_WITDH-1 downto 0) := (others => '0');
        signal lut_data : std_logic_vector(G_WITDH-1 downto 0) := (others => '0');
        type state is (IDLE, READING, CALC, WRITING, RESET);
        signal FSM_state : state := IDLE;
        constant ADDR_DIVIDER : integer := integer(ceil(log2(real(G_LUT_DEPTH))));
        constant ADDR_OFFSET  : integer := 2 ** (ADDR_DIVIDER-1);
        signal debug : integer; 

        type rom_type is array(0 to G_LUT_DEPTH-1) of std_logic_vector(G_WITDH-1 downto 0);
        constant LUT_ARCTAN : rom_type := (
            0 => x"C000",
            1 => x"C052",
            2 => x"C0A5",
            3 => x"C0F8",
            4 => x"C14C",
            5 => x"C1A0",
            6 => x"C1F5",
            7 => x"C24B",
            8 => x"C2A1",
            9 => x"C2F8",
            10 => x"C350",
            11 => x"C3A8",
            12 => x"C402",
            13 => x"C45B",
            14 => x"C4B6",
            15 => x"C511",
            16 => x"C56D",
            17 => x"C5CA",
            18 => x"C627",
            19 => x"C685",
            20 => x"C6E4",
            21 => x"C744",
            22 => x"C7A4",
            23 => x"C805",
            24 => x"C867",
            25 => x"C8C9",
            26 => x"C92D",
            27 => x"C991",
            28 => x"C9F6",
            29 => x"CA5B",
            30 => x"CAC2",
            31 => x"CB29",
            32 => x"CB91",
            33 => x"CBF9",
            34 => x"CC63",
            35 => x"CCCD",
            36 => x"CD38",
            37 => x"CDA4",
            38 => x"CE11",
            39 => x"CE7E",
            40 => x"CEEC",
            41 => x"CF5B",
            42 => x"CFCB",
            43 => x"D03C",
            44 => x"D0AD",
            45 => x"D120",
            46 => x"D193",
            47 => x"D207",
            48 => x"D27C",
            49 => x"D2F1",
            50 => x"D368",
            51 => x"D3DF",
            52 => x"D457",
            53 => x"D4D0",
            54 => x"D54A",
            55 => x"D5C4",
            56 => x"D640",
            57 => x"D6BC",
            58 => x"D739",
            59 => x"D7B7",
            60 => x"D835",
            61 => x"D8B5",
            62 => x"D935",
            63 => x"D9B6",
            64 => x"DA38",
            65 => x"DABB",
            66 => x"DB3F",
            67 => x"DBC3",
            68 => x"DC48",
            69 => x"DCCE",
            70 => x"DD55",
            71 => x"DDDD",
            72 => x"DE65",
            73 => x"DEEE",
            74 => x"DF78",
            75 => x"E003",
            76 => x"E08F",
            77 => x"E11B",
            78 => x"E1A8",
            79 => x"E236",
            80 => x"E2C4",
            81 => x"E354",
            82 => x"E3E3",
            83 => x"E474",
            84 => x"E506",
            85 => x"E598",
            86 => x"E62A",
            87 => x"E6BE",
            88 => x"E752",
            89 => x"E7E7",
            90 => x"E87C",
            91 => x"E912",
            92 => x"E9A9",
            93 => x"EA40",
            94 => x"EAD8",
            95 => x"EB71",
            96 => x"EC0A",
            97 => x"ECA4",
            98 => x"ED3E",
            99 => x"EDD9",
            100 => x"EE74",
            101 => x"EF10",
            102 => x"EFAC",
            103 => x"F049",
            104 => x"F0E6",
            105 => x"F184",
            106 => x"F222",
            107 => x"F2C0",
            108 => x"F35F",
            109 => x"F3FE",
            110 => x"F49E",
            111 => x"F53E",
            112 => x"F5DE",
            113 => x"F67F",
            114 => x"F720",
            115 => x"F7C1",
            116 => x"F863",
            117 => x"F904",
            118 => x"F9A6",
            119 => x"FA48",
            120 => x"FAEA",
            121 => x"FB8D",
            122 => x"FC2F",
            123 => x"FCD2",
            124 => x"FD75",
            125 => x"FE18",
            126 => x"FEBB",
            127 => x"FF5E",
            128 => x"0000",
            129 => x"00A2",
            130 => x"0145",
            131 => x"01E8",
            132 => x"028B",
            133 => x"032E",
            134 => x"03D1",
            135 => x"0473",
            136 => x"0516",
            137 => x"05B8",
            138 => x"065A",
            139 => x"06FC",
            140 => x"079D",
            141 => x"083F",
            142 => x"08E0",
            143 => x"0981",
            144 => x"0A22",
            145 => x"0AC2",
            146 => x"0B62",
            147 => x"0C02",
            148 => x"0CA1",
            149 => x"0D40",
            150 => x"0DDE",
            151 => x"0E7C",
            152 => x"0F1A",
            153 => x"0FB7",
            154 => x"1054",
            155 => x"10F0",
            156 => x"118C",
            157 => x"1227",
            158 => x"12C2",
            159 => x"135C",
            160 => x"13F6",
            161 => x"148F",
            162 => x"1528",
            163 => x"15C0",
            164 => x"1657",
            165 => x"16EE",
            166 => x"1784",
            167 => x"1819",
            168 => x"18AE",
            169 => x"1942",
            170 => x"19D6",
            171 => x"1A68",
            172 => x"1AFA",
            173 => x"1B8C",
            174 => x"1C1D",
            175 => x"1CAC",
            176 => x"1D3C",
            177 => x"1DCA",
            178 => x"1E58",
            179 => x"1EE5",
            180 => x"1F71",
            181 => x"1FFD",
            182 => x"2088",
            183 => x"2112",
            184 => x"219B",
            185 => x"2223",
            186 => x"22AB",
            187 => x"2332",
            188 => x"23B8",
            189 => x"243D",
            190 => x"24C1",
            191 => x"2545",
            192 => x"25C8",
            193 => x"264A",
            194 => x"26CB",
            195 => x"274B",
            196 => x"27CB",
            197 => x"2849",
            198 => x"28C7",
            199 => x"2944",
            200 => x"29C0",
            201 => x"2A3C",
            202 => x"2AB6",
            203 => x"2B30",
            204 => x"2BA9",
            205 => x"2C21",
            206 => x"2C98",
            207 => x"2D0F",
            208 => x"2D84",
            209 => x"2DF9",
            210 => x"2E6D",
            211 => x"2EE0",
            212 => x"2F53",
            213 => x"2FC4",
            214 => x"3035",
            215 => x"30A5",
            216 => x"3114",
            217 => x"3182",
            218 => x"31EF",
            219 => x"325C",
            220 => x"32C8",
            221 => x"3333",
            222 => x"339D",
            223 => x"3407",
            224 => x"346F",
            225 => x"34D7",
            226 => x"353E",
            227 => x"35A5",
            228 => x"360A",
            229 => x"366F",
            230 => x"36D3",
            231 => x"3737",
            232 => x"3799",
            233 => x"37FB",
            234 => x"385C",
            235 => x"38BC",
            236 => x"391C",
            237 => x"397B",
            238 => x"39D9",
            239 => x"3A36",
            240 => x"3A93",
            241 => x"3AEF",
            242 => x"3B4A",
            243 => x"3BA5",
            244 => x"3BFE",
            245 => x"3C58",
            246 => x"3CB0",
            247 => x"3D08",
            248 => x"3D5F",
            249 => x"3DB5",
            250 => x"3E0B",
            251 => x"3E60",
            252 => x"3EB4",
            253 => x"3F08",
            254 => x"3F5B",
            255 => x"3FAE"
        );

    begin
        process(clk)
            variable idx : integer := 0;
        begin
        if rst='1' then
            FSM_state <= RESET;
        else 
            if rising_edge(clk) then
                case FSM_state is
                    when IDLE =>
                        m_axi_s_tvalid <= '0';
                        lut_data <= (others => '0');
                        data <= (others => '0');
                        m_axi_s_tdata <= (others => '0');
                        s_axi_s_tready <= '1';
                        FSM_state <= READING;
                    when READING =>
                        if s_axi_s_tvalid = '1' then
                            s_axi_s_tready <= '0';
                            data <= s_axi_s_tdata;
                            FSM_state <= CALC;
                        end if;
                    when CALC =>
                        s_axi_s_tready <= '0';
                        lut_data <= LUT_ARCTAN(to_integer(shift_right(signed(data), ADDR_DIVIDER)) + ADDR_OFFSET);
                        --debug <= data;
                        FSM_state <= WRITING;

                    when WRITING =>
                        m_axi_s_tvalid <= '1';
                        if m_axi_s_tready = '1' then
                            m_axi_s_tdata <= lut_data;
                            FSM_state <= IDLE;
                        end if;

                    when RESET =>
                        FSM_state <= IDLE; 
                        
                end case;
            end if;
        end if;
        end process;
    end rtl;