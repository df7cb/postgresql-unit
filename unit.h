/* indices */
#define UNIT_m		0 /* meter */
#define UNIT_kg		1 /* kilogram */
#define UNIT_s		2 /* second */
#define UNIT_A		3 /* ampere */
#define UNIT_K		4 /* kelvin */
#define UNIT_mol	5 /* mole */
#define UNIT_cd		6 /* candela */
#define UNIT_B		7 /* byte */

#define N_UNITS		8

/* derived units */
#define UNIT_Hz		8
#define UNIT_N		9

/*
radian          rad      angle                                                                  m·m−1
steradian       sr       solid angle                                                            m2·m−2
hertz           Hz       frequency                                                              s−1
newton          N        force, weight                                                          kg·m·s−2
pascal          Pa       pressure, stress                                                N/m2   kg·m−1·s−2
joule           J        energy, work, heat                                              N·m    kg·m2·s−2
watt            W        power, radiant flux                                             J/s    kg·m2·s−3
coulomb         C        electric charge or quantity of electricity                             s·A
volt            V        voltage (electrical potential difference), electromotive force  W/A    kg·m2·s−3·A−1
farad           F        electric capacitance                                            C/V    kg−1·m−2·s4·A2
ohm             Ω        electric resistance, impedance, reactance                       V/A    kg·m2·s−3·A−2
siemens         S        electrical conductance                                          A/V    kg−1·m−2·s3·A2
weber           Wb       magnetic flux                                                   V·s    kg·m2·s−2·A−1
tesla           T        magnetic flux density                                           Wb/m2  kg·s−2·A−1
henry           H        inductance                                                      Wb/A   kg·m2·s−2·A−2
degree Celsius  °C       temperature relative to 273.15                                  K      K
lumen           lm       luminous flux                                                   cd·sr  cd
lux             lx       illuminance                                                     lm/m2  m−2·cd
becquerel       Bq       radioactivity (decays per unit time)                                   s−1
gray            Gy       absorbed dose (of ionizing radiation)                           J/kg   m2·s−2
sievert         Sv       equivalent dose (of ionizing radiation)                         J/kg   m2·s−2
katal           kat      catalytic activity                                                     mol·s−1
*/

/* constant */
#define UNIT_unity	0

typedef struct Unit {
	double			value;
	signed char		units[N_UNITS];
} Unit;

