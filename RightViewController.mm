#import "RightViewController.h"


@interface RightViewController()

@property (strong, nonatomic) UITableViewCell *saveNameCell;
@property (strong, nonatomic) UITableViewCell *saveGameCell;
@property (strong, nonatomic) UITableViewCell *overwriteCell;

@property (strong, nonatomic) UITextField *saveNameText;
@property (strong, nonatomic) NSArray *filePathsArray;
@property (strong, nonatomic) NSString *documentsDirectory;

@end

@implementation RightViewController

- (void)loadView
{
    [super loadView];
    
    // Set up our game saver
    gameSaver = [[GameSaver alloc] init];
    
    // set the title
    self.title = @"Save Files";

    // construct save name cell, section 0, row 0
    self.saveNameCell = [[UITableViewCell alloc] init];
    self.saveNameCell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    self.saveNameText = [[UITextField alloc]initWithFrame:CGRectInset(self.saveNameCell.contentView.bounds, 15, 0)];
    self.saveNameText.placeholder = @"Save Game Name";
    [self.saveNameCell addSubview:self.saveNameText];
    
    // construct overwrite cell, section 0, row 1
    self.overwriteCell = [[UITableViewCell alloc]init];
    self.overwriteCell.textLabel.text = @"Overwrite existing file";
    self.overwriteCell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    self.overwriteCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    // construct save game cell, section 0, row 2
    self.saveGameCell = [[UITableViewCell alloc] init];
    self.saveGameCell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    self.saveGameCell.textLabel.text = @"Save Current Game";
    
    [self updateFileList];
}

//#pragma Table View Data Source

// Return the number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// Return the number of rows for each section in your static table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:  return 3;  // section 0 has 3 rows
        case 1:  return [self.filePathsArray count];  // section 1 has a dynamic number of rows
        default: return 0;
    };
}

// Return the row for the corresponding section and row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
          switch(indexPath.row)
          {
            case 0: return self.saveNameCell;      // section 0, row 0 is the first name
            case 1: return self.overwriteCell;     // section 0, row 1 is the overwrite option
            case 2: return self.saveGameCell;      // section 0, row 2 is the last name
          }
        break;
        case 1: 
          static NSString *CellIdentifier = @"newCell";
          UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

          if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
          }
          cell.textLabel.text = [self.filePathsArray objectAtIndex:indexPath.row];
          return cell;
        break;
    };
    return nil;
}

//#pragma Table View Delegate

// Customize the section headings for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return @"Save";
        case 1: return @"Restore";
    };
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  switch(indexPath.section)
  {
    case 0:return NO;
    case 1:return YES;
  };
  return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  [gameSaver deleteSaveFile:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
  [self updateFileList];
  [self.tableView reloadData];
}

// Configure the row selection code for any cells that you want to customize the row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Handle social cell selection to toggle checkmark
    switch(indexPath.section)
    {
      case 0:
        switch(indexPath.row)
        {
          case 1:
            // deselect row
            [tableView deselectRowAtIndexPath:indexPath animated:false];
            
            // toggle check mark
            if(self.overwriteCell.accessoryType == UITableViewCellAccessoryNone) {
              self.overwriteCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
              self.overwriteCell.accessoryType = UITableViewCellAccessoryNone;
            }
          break;
          case 2:
            // deselect row
            [tableView deselectRowAtIndexPath:indexPath animated:false];
            
            // Save the file
            if(self.overwriteCell.accessoryType == UITableViewCellAccessoryNone) {
              [gameSaver doSave:self.saveNameText.text];
            } else {
              [gameSaver doSaveOverwrite:self.saveNameText.text];
            }
            [self updateFileList];
            [self.tableView reloadData];
          break;
        };
      break;
      case 1:
        [gameSaver doRestore:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
      break;
    }
}
- (void)updateFileList
{
  self.filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:@"/var/mobile/Library/FTLsaver/saves" error:nil];
}

@end