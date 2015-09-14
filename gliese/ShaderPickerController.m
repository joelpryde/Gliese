//
//  ShaderPickerController.m
//  jecTil
//
//  Created by Joel Pryde on 10/10/10.
//  Copyright 2010 PhysiPop. All rights reserved.
//

#import "ShaderPickerController.h"
#import "ShaderManager.h"
#import "Shader.h"

@implementation ShaderPickerController

@synthesize delegate = _delegate;

// Add viewDidLoad like the following:
- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(200.0, 400.0);
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return NO;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[ShaderManager Instance].shaders count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    NSString* shaderName = [[[ShaderManager Instance].shaders allKeys] objectAtIndex:indexPath.row];
    cell.textLabel.text = shaderName;
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (_delegate != nil) 
	{
        Shader *shader;
        shader = [[[ShaderManager Instance].shaders allValues] objectAtIndex:indexPath.row];
		[_delegate shaderSelected:shader];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
	_delegate = nil;
    
}


@end

