from datetime import date, datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, validator


class PgConnDetails(BaseModel):
    host: str
    port: str
    dbname: str
    user: str
    password: str


class Issue(BaseModel):
    id: int
    project_id: int
    title: str
    description: Optional[str]
    state: str
    labels: List[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime
    closed_at: Optional[datetime]
    due_date: Optional[date]

    # @validator("created_at", pre=True)
    # def parse_created_at(cls, value):
    #     print(value, type(value))
    #     return datetime.fromisoformat(value)

    # @validator("updated_at", pre=True)
    # def parse_updated_at(cls, value):
    #     return datetime.fromisoformat(value)

    # @validator("closed_at", pre=True)
    # def parse_closed_at(cls, value):
    #     return None if value is None else datetime.fromisoformat(value)

    # @validator("due_date", pre=True)
    # def parse_due_date(cls, value):
    #     return None if value is None else date.fromisoformat(value)
