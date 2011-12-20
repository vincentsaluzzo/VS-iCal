//
//  iCalCalendar.h
//  iCal Facade Library
//
//  Created by Vincent Saluzzo on 11/04/11.
//  Copyright 2011 Vincent Saluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CalendarStore/CalendarStore.h>

/**
    Direct interface of an iCal Calendar and a program
*/
@interface iCalCalendar : NSObject {
@private
    CalCalendar* Calendar;          /// CalendarStore Framework representation of an iCal Calendar
    NSMutableArray* Events;         /// List of CalEvent in this iCal Calendar
    NSMutableArray* Tasks;          /// List of CalTask in this iCal Calendar
}

@property(readwrite, retain) CalCalendar* Calendar;
@property(readwrite, retain) NSMutableArray* Events;
@property(readwrite, retain) NSMutableArray* Tasks;


/**
    init a access point for an iCal calendar with two options:
        - forceCreation: allow the program to create the calendar if isn't already in iCal
        - deleteIfExist: allow the program to delete the calendar if already existing in iCal
*/
-(id)initWithCalendar:(NSString*)pName forceCreation:(BOOL)forced deleteIfExist:(BOOL)pDelete;

/**
    function to populate the iCalCalendar object with the Task and Event owned
*/
-(void)populateCalendar;

/**
    function to populate the iCalCalendar object with the Task and Event owned only for one year
*/
-(void)populateCalendarFor:(NSInteger) pYear;



/**
    function to get all events in the iCalCalendar
*/
-(NSMutableArray*) getEvents;

/**
    function to add an event in the iCalCalendar
 */
-(BOOL) addEvent: (CalEvent*) pEvent;

/**
    function to update an existing event in the iCalCalendar
 */
-(BOOL) updateEvent:(CalEvent*)pNewEvent;

/**
    function to delete the event in iCalCalendar
 */
-(BOOL) deleteEvent:(CalEvent*)pEvent;

/**
 function to delete the event in iCalCalendar with the UID of it
 */
-(BOOL) deleteEventWithUID:(NSString*)pUid;


/**
    function to get all task in the iCalCalendar
 */
-(NSMutableArray*) getTasks;

/**
    function to add a task in the iCalCalendar
 */
-(BOOL) addTask: (CalTask*) pTask;

/**
    function to update an existing task in the iCalCalendar
 */
-(BOOL) updateTask:(CalTask*)pNewTask;

/**
    function to delete the event in iCalCalendar
 */
-(BOOL) deleteTask:(CalTask*)pTask;

/**
    function to delete the event in iCalCalendar with the UID of it
 */
-(BOOL) deleteTaskWithUID:(NSString*)pUid;


/**
    fucntion to used for refreshing the events and task owned by the iCal Calendar in the iCalCalendar Object
 */
-(void)refreshCalendar;
@end
