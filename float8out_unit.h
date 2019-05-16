/* minimal version of PG 9.6's float8out_internal function for use in 9.4 and 9.5 */
/* With the adaption of ryn in PG 12, it is now used for all versions */

#define MAXDOUBLEWIDTH	128
extern int		extra_float_digits;

static char *
float8out_unit(double num)
{
	char	   *ascii = (char *) palloc(MAXDOUBLEWIDTH + 1);
	int			extradigits =
#if PG_VERSION_NUM >= 120000
					extra_float_digits == 1 ? 0 : extra_float_digits;
#else
					extra_float_digits;
#endif
	int			ndig = DBL_DIG + extradigits;

	if (isnan(num))
		return strcpy(ascii, "NaN");
	if (!isfinite(num)) {
		if (num > 0)
			return strcpy(ascii, "Infinity");
		else
			return strcpy(ascii, "-Infinity");
	}

	if (ndig < 1)
		ndig = 1;

	snprintf(ascii, MAXDOUBLEWIDTH + 1, "%.*g", ndig, num);

	return ascii;
}
