#include "TestObject_p.h"

// ////////////////////////////////////////////////////////////////////
// private

int TestObjectPrivate::privateFunction()
{
	return 4;
}

// ////////////////////////////////////////////////////////////////////
// public
TestObject::TestObject()
	: d_ptr( new TestObjectPrivate )
{

}

TestObject::~TestObject()
{
	delete d_ptr;
}

int TestObject::publicFunction()
{
	const int val = 2;
	return d_ptr->privateFunction()>val ? d_ptr->privateFunction() : val;
}

