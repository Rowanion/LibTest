#include <iostream>

#include "TestObject.h"


int main( int argc, char* argv[] )
{
	TestObject obj;
	const int res = obj.publicFunction();
	return res == 4 ? 0 : 1;
}