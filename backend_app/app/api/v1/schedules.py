from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.schedule import Schedule, Reminder
from app.schemas.schedule import ScheduleCreate, ScheduleResponse

router = APIRouter(prefix="/schedules", tags=["Schedules"])

@router.post("/", response_model=ScheduleResponse)
def create_schedule(schedule: ScheduleCreate, db: Session = Depends(get_db)):
    db_schedule = Schedule(
        user_id=schedule.user_id,
        title=schedule.title,
        location=schedule.location,
        description=schedule.description,
        datetime=schedule.datetime,
        linked_page_id=schedule.linked_page_id,
        is_recurring=schedule.is_recurring,
        recurrence_rule=schedule.recurrence_rule,
        status=schedule.status,
    )
    db.add(db_schedule)
    db.commit()
    db.refresh(db_schedule)

    if schedule.reminders:
        for rem in schedule.reminders:
            db_reminder = Reminder(**rem.model_dump(), schedule_id=db_schedule.id)
            db.add(db_reminder)
        db.commit()
        db.refresh(db_schedule)

    return db_schedule

@router.get("/{user_id}", response_model=List[ScheduleResponse])
def get_schedules(user_id: str, db: Session = Depends(get_db)):
    return db.query(Schedule).filter(Schedule.user_id == user_id).all()

@router.delete("/{schedule_id}")
def delete_schedule(schedule_id: int, db: Session = Depends(get_db)):
    db_schedule = db.query(Schedule).filter(Schedule.id == schedule_id).first()
    if not db_schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    db.delete(db_schedule)
    db.commit()
    return {"message": "Schedule deleted successfully"}