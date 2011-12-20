//
//  iCalCalendar.m
//  iCal Facade Library
//
//  Created by Vincent Saluzzo on 11/04/11.
//  Copyright 2011 Vincent Saluzzo. All rights reserved.
//

#import "iCalCalendar.h"


@implementation iCalCalendar
@synthesize Calendar;
@synthesize Events;
@synthesize Tasks;

- (id)init
{
    self = [super init];
    if (self) {
        self.Calendar = nil;
        self.Events = nil;
    }
    
    return self;
}

- (id)initWithCalendar:(NSString*)pName forceCreation:(BOOL)forced deleteIfExist:(BOOL)pDelete {
    self = [self init];
    if (self) {
        NSArray* listOfCalendars = [[CalCalendarStore defaultCalendarStore] calendars];
       
        for (int i = 0; i < [listOfCalendars count]; i++) {
            CalCalendar* cal = [listOfCalendars objectAtIndex:i];
            NSString* bite = [[NSString alloc] initWithString:[cal title]];
            if ([bite isEqualToString:pName]) {
                self.Calendar = cal;
            }
        }
        if(self.Calendar != nil) {
            NSError* calError;
            [[CalCalendarStore defaultCalendarStore] removeCalendar:Calendar error:&calError];
        }
        if(self.Calendar == nil) {
            if(forced == NO) {
                return nil;
            } else {
                CalCalendar* newCalendar = [CalCalendar calendar];
                newCalendar.title = pName;
                NSError* calError;
                [[CalCalendarStore defaultCalendarStore] saveCalendar:newCalendar error:&calError];
                self.Calendar = newCalendar;
            }
        } 
        
        self.Events = [[NSMutableArray alloc] init];
        self.Tasks = [[NSMutableArray alloc] init];
        [self populateCalendar];
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    [Calendar release];
}


-(void)populateCalendar {
    if(self.Calendar == nil){
        NSException* exception = [NSException
                        exceptionWithName:@"NilException"
                        reason:@"Calendar is set to nil"
                        userInfo:nil];
        @throw exception;
    } else {
        NSInteger year = [[NSCalendarDate date] yearOfCommonEra];
        for(NSInteger i = year-30; i < year+30; i++) {
            [self populateCalendarFor:i];
        }
    }
    
    NSPredicate *predicate = [CalCalendarStore taskPredicateWithCalendars:[[CalCalendarStore defaultCalendarStore] calendars]];
    NSArray *tasks = [[CalCalendarStore defaultCalendarStore] tasksWithPredicate:predicate];
    for(int i = 0; i < [tasks count]; i++) {
        CalTask* task = [tasks objectAtIndex:i];
        
        if([[[task calendar] uid] isEqualToString:[Calendar uid]]) {
            [Tasks addObject:task];
        }
    }
    
}

-(void) populateCalendarFor:(NSInteger)pYear {
    NSDate *startDate = [[NSCalendarDate dateWithYear:pYear 
                                                month:1 
                                                  day:1 
                                                 hour:0 
                                               minute:0 
                                               second:0 
                                             timeZone:nil] 
                         retain];
    
    NSDate *endDate = [[NSCalendarDate dateWithYear:pYear 
                                              month:12 
                                                day:31 
                                               hour:23 
                                             minute:59 
                                             second:59 
                                           timeZone:nil] 
                       retain];
    
    NSPredicate *eventsForThisYear = [CalCalendarStore eventPredicateWithStartDate:startDate 
                                                                           endDate:endDate 
                                                                         calendars:[[CalCalendarStore defaultCalendarStore] calendars]];
    
    NSArray *events = [[CalCalendarStore defaultCalendarStore] eventsWithPredicate:eventsForThisYear];
    
    for(int i = 0; i < [events count]; i++) {
        CalEvent* evnt = [events objectAtIndex:i];
        NSString* evntCalendarUid = [[evnt calendar] uid];
        
        if([evntCalendarUid isEqualToString:[self.Calendar uid]]) {
            [self.Events addObject:evnt];
        }
        
    }

}

-(NSMutableArray*) getEvents {
    return self.Events;
}

-(BOOL)addEvent: (CalEvent*) pEvent {
    pEvent.calendar = self.Calendar;
    NSError *calError;
    BOOL result = [[CalCalendarStore defaultCalendarStore] saveEvent:pEvent span:CalSpanAllEvents error:&calError];
    [self refreshCalendar];
    return result;
}

-(BOOL)updateEvent: (CalEvent *)pNewEvent {
    if([Events containsObject:pNewEvent]) {
        NSError *calError;
        BOOL result = [[CalCalendarStore defaultCalendarStore] saveEvent:pNewEvent span:CalSpanAllEvents error:&calError];
        [self refreshCalendar];
        return result;
    } else {
        return NO;
    }
}

-(BOOL)deleteEvent:(CalEvent *)pEvent {
    if([Events containsObject:pEvent]) {
        NSError *calError;
        BOOL result = [[CalCalendarStore defaultCalendarStore] removeEvent:pEvent span:CalSpanAllEvents error:&calError];
        [self refreshCalendar];
        return result;
    } else {
        return NO;
    }
}

-(BOOL)deleteEventWithUID:(NSString *)pUid {
    CalEvent* event = nil;
    for(int i = 0; i < [Events count]; i++) {
        if([[[Events objectAtIndex:i] uid] isEqualToString:pUid]) {
            event = [Events objectAtIndex:i];
        }
    }
    
    if(event != nil) {
        NSError *calError;
        BOOL result = [[CalCalendarStore defaultCalendarStore] removeEvent:event span:CalSpanAllEvents error:&calError];
        [self refreshCalendar];
        return result;
    } else {
        return NO;
    }
}

-(NSMutableArray*) getTasks {
    return self.Tasks;
}

-(BOOL)addTask:(CalTask *)pTask {
    pTask.calendar = self.Calendar;
    NSError *calError;
    BOOL result = [[CalCalendarStore defaultCalendarStore] saveTask:pTask error:&calError];
    [self refreshCalendar];
    return result;
}

-(BOOL)updateTask:(CalTask *)pNewTask {
    if([Tasks containsObject:pNewTask]) {
        NSError *calError;
        BOOL result = [[CalCalendarStore defaultCalendarStore] saveTask:pNewTask error:&calError];
        [self refreshCalendar];
        return result;
    } else {
        return NO;
    }
}

-(BOOL)deleteTask:(CalTask *)pTask {
    if([Tasks containsObject:pTask]) {
        NSError *calError;
        BOOL result = [[CalCalendarStore defaultCalendarStore] removeTask:pTask error:&calError];
        [self refreshCalendar];
        return result;
    } else {
        return NO;
    }
}

-(BOOL)deleteTaskWithUID:(NSString *)pUid {
    CalTask* task = nil;
    for(int i = 0; i < [Tasks count]; i++) {
        if([[[Tasks objectAtIndex:i] uid] isEqualToString:pUid]) {
            task = [Tasks objectAtIndex:i];
        }
    }
    
    if(task != nil) {
        NSError *calError;
        BOOL result = [[CalCalendarStore defaultCalendarStore] removeTask:task error:&calError];
        [self refreshCalendar];
        return result;
    } else {
        return NO;
    }
}


-(void)refreshCalendar {
    [self.Events release];
    [self.Tasks release];
    self.Events = [[NSMutableArray alloc] init];
    self.Tasks = [[NSMutableArray alloc] init];
    [self populateCalendar];
}

@end
