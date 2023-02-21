from datetime import date, datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel


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
