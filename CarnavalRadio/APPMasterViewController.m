//
//  APPMasterViewController.m
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPMasterViewController.h"
#import <STKAudioPlayer.h>
#import "APPDetailViewController.h"
#import <MarqueeLabel.h>


@interface APPMasterViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSString *element;
    STKAudioPlayer* audioPlayer;
    MarqueeLabel *lectureName;
    NSTimer *timer;
    bool isPlay;
}


@end

@implementation APPMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://www.carnavalradio.es/feed"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

-(void)viewWillAppear:(BOOL)animated{

    self.navigationItem.title =@"Carnaval Radio informa";
    [self moveLabelText];
    isPlay= true;
    [self buttonPlayMusic:nil];
     timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cambiaTexto:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    lectureName.text = @"";
    [super viewWillDisappear:animated];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];

     [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    
    NSUInteger row=indexPath.row;
    if (row % 2==0){
        [cell setBackgroundColor: [self colorWithHexString:@"b9d4e9"]];
    }else{
        [cell setBackgroundColor: [self colorWithHexString:@"99c7ea"]];
    }

    return cell;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        
        [feeds addObject:[item copy]];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    [self.tableView reloadData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [[segue destinationViewController] setUrl:string];
        
    }
}

- (IBAction)buttonPlayMusic:(id)sender {

    
    if(audioPlayer== nil)
        audioPlayer = [[STKAudioPlayer alloc] init];
    [audioPlayer play:@"http://5.135.183.124:8019/stream"];
    if(isPlay){
        [self.botonPlay setImage:[UIImage imageNamed:@"botonStop"] forState:UIControlStateNormal];
        isPlay=false;
    } else{
        [self.botonPlay setImage:[UIImage imageNamed:@"botonPlay"] forState:UIControlStateNormal];
        [audioPlayer stop];
        lectureName.text = @"Pulse play pra escuchar Carnaval Radio...";
        isPlay=true;
    }
    
    
}



-(NSString *)getTituloCancion{
    NSString *result = nil;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *localPath = [path objectAtIndex:0]; //The apps document directory

    NSString* fileURL = @"http://www.carnavalradio.es/metadata/CurrentSong.txt";
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];

    if (!(data==nil)) {
        [data writeToFile:[localPath stringByAppendingPathComponent:@"CurrentSong.txt"] atomically:YES];
        NSLog(@"Did download file: CurrentSong.txt");
    }

    NSData *txtData = [NSData dataWithContentsOfFile:[[self getDocumentDirectory] stringByAppendingPathComponent:@"CurrentSong.txt"]];
    if(!(txtData==nil)) {
        result =    [[NSString alloc] initWithData:txtData encoding:NSUTF8StringEncoding];
        if(!result)
            result = [NSString stringWithUTF8String:[txtData bytes]];
        if(result)
            return result;
    }
    
    return @"Realizando búsqueda del título de la canción que está sonando..";
}

-(NSString *) getDocumentDirectory {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        return [path objectAtIndex:0]; //The apps document directory
}

- (void)moveLabelText {
    if(lectureName==nil){
        lectureName = [[MarqueeLabel alloc] initWithFrame:CGRectMake(10, self.barraBaja.frame.size.height/2 -10, 250, 20) duration:5.0 andFadeLength:10.0f];
        [self.barraBaja addSubview:lectureName];
    [lectureName setBackgroundColor:[UIColor clearColor]];
    lectureName.adjustsFontSizeToFitWidth=NO;
    [lectureName setTextColor:[UIColor whiteColor]];
    lectureName.text= @"Realizando búsqueda del título de la canción que está sonando";
    [lectureName setAnimationCurve:UIViewAnimationOptionCurveEaseIn];
    [lectureName setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    }

}

-(void)cambiaTexto:(NSTimer *) timer{
    [lectureName setText:[self getTituloCancion]];
   
}


-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
