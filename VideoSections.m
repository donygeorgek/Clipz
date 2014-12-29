//
//  VideoSections.m
//  Clipz
//
//  Created by APPLE on 10/12/14.
//  Copyright (c) 2014 Notion TechLabs. All rights reserved.
//

#import "VideoSections.h"
#import "FeaturedVideos.h"

@interface VideoSections ()

@end

@implementation VideoSections

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sectionNames=[[NSArray alloc] initWithObjects:@"Featured items",@"Recent Items (Popular)",@"Recent Items (All)",@"Top Items (Today)",@"Top Items (This Week)",@"Top Items (This Month)",@"Top Items (All time)", @"Upcoming Videos",nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [sectionNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"sectionCell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text=[sectionNames objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:16];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Video Menu";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"FeaturedVideos" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FeaturedVideos"])
    {
        FeaturedVideos *view =segue.destinationViewController;
        
        int row=([sender row]+1);
        if (row==1) {
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Featured Videos";
        }else if (row==2){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Recent Videos (Popular)";
        }else if (row==3){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Recent Videos (All)";
        }else if (row==4){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Top Videos (Today)";
        }else if (row==5){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Top Videos (Week)";
        }else if (row==6){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Top Videos (Month)";
        }else if (row==7){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Top Videos (All)";
        }else if (row==8){
            view.categoryString=[NSString stringWithFormat:@"%d",row];
            view.title = @"Upcoming Videos";
        }
        
        [view loadVideos:1];
    }
}

@end
