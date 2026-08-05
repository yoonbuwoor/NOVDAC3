#!/usr/bin/env python3
"""Valide le catalogue pédagogique statique de DroneAtlas."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
MANIFEST = CONTENT / "manifest.json"


class ValidationError(Exception):
    pass


def load_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ValidationError(f"Fichier absent : {path.relative_to(ROOT)}") from exc
    except json.JSONDecodeError as exc:
        raise ValidationError(
            f"JSON invalide dans {path.relative_to(ROOT)} : ligne {exc.lineno}, colonne {exc.colno}"
        ) from exc
    if not isinstance(data, dict):
        raise ValidationError(f"La racine de {path.relative_to(ROOT)} doit être un objet JSON.")
    return data


def require_text(data: dict[str, Any], key: str, source: str) -> str:
    value = data.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValidationError(f"{source} : le champ « {key} » est obligatoire.")
    return value.strip()


def validate_course(path: Path, expected_id: str, expected_version: int) -> None:
    data = load_json(path)
    source = str(path.relative_to(ROOT))
    course_id = require_text(data, "id", source)
    if course_id != expected_id:
        raise ValidationError(
            f"{source} : id « {course_id} » différent de celui du manifest « {expected_id} »."
        )
    version = data.get("version")
    if not isinstance(version, int) or version < 1:
        raise ValidationError(f"{source} : version doit être un entier positif.")
    if version != expected_version:
        raise ValidationError(
            f"{source} : version {version} différente de celle du manifest {expected_version}."
        )
    for field in ("title", "summary", "category", "duration", "level"):
        require_text(data, field, source)

    objectives = data.get("objectives")
    if not isinstance(objectives, list) or len(objectives) < 2 or not all(
        isinstance(item, str) and item.strip() for item in objectives
    ):
        raise ValidationError(f"{source} : ajoute au moins deux objectifs valides.")

    pages = data.get("pages")
    if not isinstance(pages, list) or not pages:
        raise ValidationError(f"{source} : le cours doit contenir au moins une page.")
    for index, page in enumerate(pages, start=1):
        if not isinstance(page, dict):
            raise ValidationError(f"{source} : page {index} invalide.")
        require_text(page, "title", f"{source}, page {index}")
        require_text(page, "body", f"{source}, page {index}")

    quiz = data.get("quiz")
    if not isinstance(quiz, dict):
        raise ValidationError(f"{source} : objet quiz absent.")
    require_text(quiz, "question", f"{source}, quiz")
    require_text(quiz, "explanation", f"{source}, quiz")
    answers = quiz.get("answers")
    if not isinstance(answers, list) or len(answers) < 2 or not all(
        isinstance(item, str) and item.strip() for item in answers
    ):
        raise ValidationError(f"{source} : le quiz doit avoir au moins deux réponses.")
    correct = quiz.get("correctAnswer")
    if not isinstance(correct, int) or not 0 <= correct < len(answers):
        raise ValidationError(f"{source} : correctAnswer est hors limites.")


def main() -> int:
    try:
        manifest = load_json(MANIFEST)
        if manifest.get("schemaVersion") != 1:
            raise ValidationError("content/manifest.json : schemaVersion doit valoir 1.")
        version = manifest.get("contentVersion")
        if not isinstance(version, int) or version < 1:
            raise ValidationError("content/manifest.json : contentVersion doit être positif.")
        for field in ("publishedAt", "title", "description"):
            require_text(manifest, field, "content/manifest.json")

        courses = manifest.get("courses")
        if not isinstance(courses, list) or not courses:
            raise ValidationError("content/manifest.json : la liste courses est vide.")

        seen: set[str] = set()
        for index, summary in enumerate(courses, start=1):
            if not isinstance(summary, dict):
                raise ValidationError(f"manifest : cours {index} invalide.")
            source = f"manifest, cours {index}"
            course_id = require_text(summary, "id", source)
            if course_id in seen:
                raise ValidationError(f"manifest : identifiant dupliqué « {course_id} ».")
            seen.add(course_id)
            course_version = summary.get("version")
            if not isinstance(course_version, int) or course_version < 1:
                raise ValidationError(f"{source} : version invalide.")
            for field in ("title", "summary", "category", "duration", "url"):
                require_text(summary, field, source)
            relative_url = summary["url"]
            if relative_url.startswith(("http://", "https://", "/")) or ".." in Path(relative_url).parts:
                raise ValidationError(f"{source} : l’URL doit rester relative au dossier content.")
            course_path = (CONTENT / relative_url).resolve()
            if CONTENT.resolve() not in course_path.parents:
                raise ValidationError(f"{source} : URL hors du dossier content.")
            validate_course(course_path, course_id, course_version)

        print(
            f"Catalogue DroneAtlas valide : version {version}, "
            f"{len(courses)} cours, {len(seen)} identifiants uniques."
        )
        return 0
    except ValidationError as exc:
        print(f"ERREUR : {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
