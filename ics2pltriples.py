#!/usr/bin/env python2.7
from icalendar import Calendar
import datetime

def to_prolog_date(d):
    if isinstance(d, datetime.datetime):
        return u'date(%d,%d,%d,%d,%d,%f,%f,\'%s\',%s)' % (d.year, d.month, d.day, d.hour, d.minute, d.second, d.utcoffset().total_seconds(), d.tzname(), 'true' if d.dst().total_seconds() > 0 else 'false')
    if isinstance(d, datetime.date):
        return u'date(%d,%d,%d,0,0,0.0,0.0,\'-\',false)' % (d.year, d.month, d.day)

def to_prolog_string(s):
    if s:
        return u'\'%s\'' % s.replace('\'','\\\'').replace('\n',' ')
    return None

def triple(a,b,c):
    return (u'triple(%s,%s,%s).' % (a, b, c)).encode('utf-8')

with open('Downloads/basic.ics') as f:
    cal = Calendar.from_ical(f.read())

print ':- multifile triple/3.'
for component in cal.walk():
    if component.name == 'VEVENT':
        uid = to_prolog_string(component.get('uid'))
        summary = to_prolog_string(component.get('summary'))
        description = to_prolog_string(component.get('description'))
        location = to_prolog_string(component.get('location'))
        sequence = component.get('sequence')
        status = to_prolog_string(component.get('status'))
        transp = to_prolog_string(component.get('transp'))
        created = to_prolog_date(component.get('created').dt)
        dtstart = to_prolog_date(component.get('dtstart').dt)
        dtend = to_prolog_date(component.get('dtend').dt)
        dtstamp = to_prolog_date(component.get('dtstamp').dt)
        print triple(uid,'type','icalentry')
        if summary: print triple(uid,'summary',summary)
        if description: print triple(uid,'description',description)
        if location: print triple(uid,'location',location)
        if sequence: print triple(uid,'sequence',sequence)
        if status: print triple(uid,'status',status)
        if transp: print triple(uid,'transp',transp)
        if created: print triple(uid,'created',created)
        if dtstart: print triple(uid,'dtstart',dtstart)
        if dtend: print triple(uid,'dtend',dtend)
        if dtstamp: print triple(uid,'dtstamp',dtstamp)
