"""
JSON Project Loader Utility
Loads project data from JSON file and creates ProjectObject instances
Also handles page configuration for determining which projects appear on each page
"""

import json
from datetime import date
from pathlib import Path
from typing import Dict, List, Optional
from utils.ProjectObject import ProjectObject

class ProjectLoader:
    """Utility class for loading projects from JSON file and page configurations"""
    
    def __init__(self, json_path: str = "projects.json", config_path: str = "page_config.json"):
        """
        Initialize the loader with paths to JSON files
        
        Args:
            json_path: Path to the projects JSON file (relative to project root)
            config_path: Path to the page configuration JSON file (relative to project root)
        """
        self.json_path = Path(json_path)
        self.config_path = Path(config_path)
        self._projects_data = None
        self._page_config = None
        self._load_json()
        self._load_config()
    
    def _load_json(self):
        """Load and parse the projects JSON file"""
        if not self.json_path.exists():
            raise FileNotFoundError(f"Projects JSON file not found: {self.json_path}")
        
        with open(self.json_path, 'r', encoding='utf-8') as f:
            self._projects_data = json.load(f)
    
    def _load_config(self):
        """Load and parse the page configuration JSON file"""
        if not self.config_path.exists():
            raise FileNotFoundError(f"Page config JSON file not found: {self.config_path}")
        
        with open(self.config_path, 'r', encoding='utf-8') as f:
            self._page_config = json.load(f)
    
    def _parse_date(self, date_str: Optional[str]) -> Optional[date]:
        """
        Parse ISO date string to date object
        
        Args:
            date_str: ISO format date string or None
            
        Returns:
            date object or None
        """
        if date_str is None:
            return None
        return date.fromisoformat(date_str)
    
    def _create_project_object(self, project_data: dict) -> ProjectObject:
        """
        Create a ProjectObject instance from JSON data
        
        Args:
            project_data: Dictionary containing project data
            
        Returns:
            ProjectObject instance
        """
        return ProjectObject(
            title=project_data.get("title"),
            description=project_data.get("description"),
            date_=self._parse_date(project_data.get("date")),
            last_update=self._parse_date(project_data.get("last_update")),
            vid_link=project_data.get("vid_link"),
            github_link=project_data.get("github_link"),
            img_paths=project_data.get("img_paths", []),
            what_i_did=project_data.get("what_i_did", []),
            tags=project_data.get("tags", []),
            project_type=project_data.get("project_type", "Full Project"),
            download_paths=project_data.get("download_paths", [])
        )
    
    def get_project(self, variable_name: str) -> Optional[ProjectObject]:
        """
        Get a single project by its variable name
        
        Args:
            variable_name: The variable name of the project (e.g., 'AI_Game')
            
        Returns:
            ProjectObject instance or None if not found
        """
        if variable_name not in self._projects_data:
            return None
        
        return self._create_project_object(self._projects_data[variable_name])
    
    def get_projects_by_category(self, category: str) -> Dict[str, ProjectObject]:
        """
        Get all projects in a specific category
        
        Args:
            category: Category name ('normal', 'mini', 'translation')
            
        Returns:
            Dictionary mapping variable names to ProjectObject instances
        """
        projects = {}
        
        for var_name, project_data in self._projects_data.items():
            if project_data.get("category") == category:
                projects[var_name] = self._create_project_object(project_data)
        
        return projects
    
    def get_all_projects(self) -> Dict[str, ProjectObject]:
        """
        Get all projects as ProjectObject instances
        
        Returns:
            Dictionary mapping variable names to ProjectObject instances
        """
        projects = {}
        
        for var_name, project_data in self._projects_data.items():
            projects[var_name] = self._create_project_object(project_data)
        
        return projects
    
    def get_projects_by_names(self, variable_names: List[str]) -> Dict[str, ProjectObject]:
        """
        Get multiple projects by their variable names
        
        Args:
            variable_names: List of variable names to retrieve
            
        Returns:
            Dictionary mapping variable names to ProjectObject instances
        """
        projects = {}
        
        for var_name in variable_names:
            project = self.get_project(var_name)
            if project is not None:
                projects[var_name] = project
        
        return projects
    
    def search_projects_by_title(self, title: str) -> Optional[ProjectObject]:
        """
        Search for a project by its title
        
        Args:
            title: The project title to search for
            
        Returns:
            ProjectObject instance or None if not found
        """
        for project_data in self._projects_data.values():
            if project_data.get("title") == title:
                return self._create_project_object(project_data)
        
        return None
    
    def get_project_names(self, category: Optional[str] = None) -> List[str]:
        """
        Get list of all project variable names, optionally filtered by category
        
        Args:
            category: Optional category to filter by
            
        Returns:
            List of variable names
        """
        if category is None:
            return list(self._projects_data.keys())
        
        return [
            var_name for var_name, project_data in self._projects_data.items()
            if project_data.get("category") == category
        ]
    
    def get_project_titles(self, category: Optional[str] = None) -> List[str]:
        """
        Get list of all project titles, optionally filtered by category
        
        Args:
            category: Optional category to filter by
            
        Returns:
            List of project titles
        """
        projects = self._projects_data.values()
        
        if category is not None:
            projects = [p for p in projects if p.get("category") == category]
        
        return [p.get("title") for p in projects]
    
    def get_page_projects(self, page_name: str) -> Dict[str, ProjectObject]:
        """
        Get all projects configured for a specific page
        
        Args:
            page_name: Name of the page (e.g., 'featured_projects', 'projects_archive', 'translations')
            
        Returns:
            Dictionary mapping project titles to ProjectObject instances
        """
        if page_name not in self._page_config.get("page_configurations", {}):
            raise ValueError(f"Page configuration not found: {page_name}")
        
        page_config = self._page_config["page_configurations"][page_name]
        project_var_names = page_config.get("projects", [])
        
        # Load projects and return as title-keyed dictionary
        projects = {}
        for var_name in project_var_names:
            project = self.get_project(var_name)
            if project is not None:
                projects[project.title] = project
        
        return projects
    
    def get_available_pages(self) -> List[str]:
        """
        Get list of all available page configurations
        
        Returns:
            List of page names
        """
        return list(self._page_config.get("page_configurations", {}).keys())
    
    def get_page_description(self, page_name: str) -> Optional[str]:
        """
        Get the description for a specific page configuration
        
        Args:
            page_name: Name of the page
            
        Returns:
            Description string or None if not found
        """
        page_config = self._page_config.get("page_configurations", {}).get(page_name, {})
        return page_config.get("description")

# Global loader instance for easy access
_loader = None

def get_loader() -> ProjectLoader:
    """
    Get the global ProjectLoader instance (singleton pattern)
    
    Returns:
        ProjectLoader instance
    """
    global _loader
    if _loader is None:
        _loader = ProjectLoader()
    return _loader


# Convenience functions that use the global loader
def load_project(variable_name: str) -> Optional[ProjectObject]:
    """Load a single project by variable name"""
    return get_loader().get_project(variable_name)

def load_projects_by_category(category: str) -> Dict[str, ProjectObject]:
    """Load all projects in a category"""
    return get_loader().get_projects_by_category(category)

def load_all_projects() -> Dict[str, ProjectObject]:
    """Load all projects"""
    return get_loader().get_all_projects()

def load_projects(variable_names: List[str]) -> Dict[str, ProjectObject]:
    """Load multiple projects by variable names"""
    return get_loader().get_projects_by_names(variable_names)

def load_projects_by_titles(titles: List[str]) -> Dict[str, ProjectObject]:
    """
    Load multiple projects by their display titles
    
    Args:
        titles: List of project titles to load
        
    Returns:
        Dictionary mapping titles to ProjectObject instances
    """
    loader = get_loader()
    projects = {}
    
    for title in titles:
        project = loader.search_projects_by_title(title)
        if project is not None:
            projects[title] = project
    
    return projects

def load_page_projects(page_name: str) -> Dict[str, ProjectObject]:
    """
    Load all projects configured for a specific page
    
    Args:
        page_name: Name of the page configuration
        
    Returns:
        Dictionary mapping project titles to ProjectObject instances
    """
    return get_loader().get_page_projects(page_name)

def get_available_pages() -> List[str]:
    """Get list of all available page configurations"""
    return get_loader().get_available_pages()

def get_page_description(page_name: str) -> Optional[str]:
    """Get description for a page configuration"""
    return get_loader().get_page_description(page_name)