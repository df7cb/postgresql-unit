/* minimal version of PG 9.6's float8out_internal function for use in 9.4 and 9.5 */

#define MAXDOUBLEWIDTH	128
extern int		extra_float_digits;

static char *
float8out_internal(double num)
{
	char	   *ascii = (char *) palloc(MAXDOUBLEWIDTH + 1);
	int			ndig = DBL_DIG + extra_float_digits;

	if (isnan(num))
		return strcpy(ascii, "NaN");

	if (ndig < 1)
		ndig = 1;

	snprintf(ascii, MAXDOUBLEWIDTH + 1, "%.*g", ndig, num);

	return ascii;
}
