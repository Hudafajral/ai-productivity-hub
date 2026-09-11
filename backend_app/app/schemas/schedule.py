from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class ReminderBase(BaseModel):
    trigger_time: datetime
    status: str = "pending"

class ReminderCreate(ReminderBase):
    pass

class ReminderResponse(ReminderBase):
    id: int
    schedule_id: int
    
    class Config:
        from_attributes = True

class ScheduleBase(BaseModel):
    user_id: str
    title: str
    location: Optional[str] = None       # <-- Menampung lokasi agenda
    description: Optional[str] = None    # <-- Menampung rincian/deskripsi kegiatan
    datetime: datetime
    linked_page_id: Optional[int] = None
    is_recurring: bool = False
    recurrence_rule: Optional[str] = None
    status: str = "active"

class ScheduleCreate(ScheduleBase):
    reminders: Optional[List[ReminderCreate]] = []

class ScheduleResponse(ScheduleBase):
    id: int
    reminders: List[ReminderResponse] = []
    
    class Config:
        from_attributes = True