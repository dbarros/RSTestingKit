//
//  Tests_ExampleHTTP.m
//  RSTestingKitExamples
//
//  Created by daniel on 10/31/10.
//  Copyright 2010 Red Sweater Software. All rights reserved.
//

#import "Tests_ExampleHTTP.h"

@interface Tests_ExampleHTTP (Private)
- (NSData*) fetchDataFromURL:(NSURL*)theURL;
@end

@implementation Tests_ExampleHTTP

- (void) testSimpleHTTPRequest
{	
	// In real life, you would be testing some of your code that in turn relies 
	// on a particular network response. Here, we just pretend that we care deeply about 
	// the ability of NSURLConnection/Request to successful transfer
	// the text string "<hello>" through the network stack.
	
	// The name used for constructing this URL must match the implementation of the "response" method below.
	NSURL* simpleHTTPRequestURL = [self serverURLForHTTPTestNamed:@"SimpleHTTPRequest"];
	NSData* responseData = [self fetchDataFromURL:simpleHTTPRequestURL];
	
	// We should have gotten the response generated below
	NSData* expectedResponseData = [@"<hello>" dataUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([responseData isEqualTo:expectedResponseData], @"Expected <hello> result, got %@.", responseData);	
}

- (GTMHTTPResponseMessage *) responseForTestRequest_SimpleHTTPRequest:(GTMHTTPRequestMessage *)request
{
	return [GTMHTTPResponseMessage responseWithHTMLString:@"<hello>"];
}

// NSURLConnection delegate stuff
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Indicate that the test is completed, so the run loop can return control
	// to the test that initiated the load
	[self setWaitingForTestCompletion:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[mCurrentRequestResponseData appendData:data];
}

- (NSData*) fetchDataFromURL:(NSURL*)theURL
{
	[mCurrentRequestResponseData release];
	mCurrentRequestResponseData = [[NSMutableData data] retain];

	NSURLRequest* theURLRequest = [NSURLRequest requestWithURL:theURL];
	STAssertNotNil(theURLRequest, @"Creation of the HTTP Request should have succeeded.");
	
	NSURLConnection* theURLConnection = [NSURLConnection connectionWithRequest:theURLRequest delegate:self];
	[theURLConnection retain];
	
	// Wait for the network transaction to finish
	[self waitForRunLoopTestCompletion];

	[theURLConnection release];
	
	// Return a the data autoreleased, and nil out the instance variable for the next fetch
	NSData* returnedData = mCurrentRequestResponseData;
	mCurrentRequestResponseData = nil;
	return [returnedData autorelease];
}

@end
