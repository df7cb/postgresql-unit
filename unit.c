#include "postgres.h"
#include "fmgr.h"

PG_MODULE_MAGIC;

void    _PG_init(void);
void    _PG_fini(void);

/*
 * Module initialization and cleanup
 */

void
_PG_init(void)
{
}

void
_PG_fini(void)
{
}

static char foo[] = "unit foo";

PG_FUNCTION_INFO_V1 (unit);

Datum
unit (PG_FUNCTION_ARGS)
{
	PG_RETURN_CSTRING (foo);
}
