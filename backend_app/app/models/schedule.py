from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
import datetime
from app.core.database import Base

class Schedule(Base):
    __tablename__ = "schedules"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, index=True)
    title = Column(String, index=True)
    location = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    datetime = Column(DateTime, default=datetime.datetime.utcnow)
    linked_page_id = Column(Integer, nullable=True)
    is_recurring = Column(Boolean, default=False)
    recurrence_rule = Column(String, nullable=True)
    status = Column(String, default="active")

    reminders = relationship("Reminder", back_populates="schedule", cascade="all, delete-orphan")

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)
    schedule_id = Column(Integer, ForeignKey("schedules.id"))
    trigger_time = Column(DateTime)
    status = Column(String, default="pending")

    schedule = relationship("Schedule", back_populates="reminders")