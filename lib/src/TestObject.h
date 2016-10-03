#pragma once

#include "libtest_export.h"

class TestObjectPrivate;
class LIBTEST_EXPORT TestObject
{
public:
	TestObject();
	virtual ~TestObject();

	int publicFunction();

protected:
	TestObjectPrivate* d_ptr;
};