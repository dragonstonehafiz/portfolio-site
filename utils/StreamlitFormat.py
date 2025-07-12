import streamlit as st
from utils.ProjectObject import ProjectObject
import re

def create_page_elements(featured_projects: dict[str, ProjectObject], page_name):
    # Get unique tags and project types
    unique_tags = get_unique_tags(featured_projects.values())
    unique_types = get_unique_project_types(featured_projects.values())
    
    # Sidebar Filters
    connect_with_me()

    st.sidebar.header("Filters")
    sort_order = st.sidebar.radio("Sort projects by date", ["Ascending", "Descending"], index=1, key=f"{page_name} radio")
    selected_tags = st.sidebar.multiselect("Filter by Tags", unique_tags, key=f"{page_name} tags")
    selected_type = st.sidebar.selectbox("Filter by Project Type", ["All"] + unique_types, key=f"{page_name} type")

    # Process projects: filter and sort
    filtered_projects = filter_projects(featured_projects.values(), selected_tags, selected_type)
    reverse_sort = sort_order == "Descending"
    filtered_projects = create_sorted_list(featured_projects, selected_tags, selected_type, reverse_sort)

    # Links
    render_and_nav(filtered_projects)


def connect_with_me():
    st.sidebar.header("Links")
    st.sidebar.page_link(
        "https://github.com/dragonstonehafiz",
        label="GitHub",
        icon=":material/code:",
        use_container_width=True
    )
    # LinkedIn
    st.sidebar.page_link(
        "https://www.linkedin.com/in/muhdhafizabdulhalim/",
        label="LinkedIn",
        icon=":material/business_center:",
        use_container_width=True
    )
    # YouTube
    st.sidebar.page_link(
        "https://www.youtube.com/@hafiz8325",
        label="YouTube",
        icon=":material/play_circle:",
        use_container_width=True
    )

# Function to create a sorted and filtered list of projects
def create_sorted_list(projects: dict[str, ProjectObject], selected_tags: set[str], selected_type: str, reverse_sort: bool):
    """
    Sorts and filters projects based on selected tags, project type, and sorting order.

    Args:
        projects (dict[str, ProjectObject]): Dictionary of project objects.
        selected_tags (set[str]): Selected tags for filtering.
        selected_type (str): Selected project type for filtering ("All" means no filter).
        reverse_sort (bool): Whether to sort in descending order.

    Returns:
        dict[str, ProjectObject]: Filtered and sorted dictionary of projects.
    """
    # Sort projects by date
    sorted_projects = {
        name: project
        for name, project in sorted(
            projects.items(),
            key=lambda item: item[1].get_date(),  # Sort by date attribute
            reverse=reverse_sort  # Descending if True, ascending if False
        )
    }

    # Filter projects based on selected tags
    filtered_projects = {
        name: project
        for name, project in sorted_projects.items()
        if (not selected_tags or (project.tags and any(tag in selected_tags for tag in project.tags)))
    }

    # Filter projects based on selected project type
    if selected_type != "All":
        filtered_projects = {
            name: project
            for name, project in filtered_projects.items()
            if project.project_type == selected_type
        }

    return filtered_projects
# Function to generate safe anchor links
def safe_anchor(text: str) -> str:
    """
    Creates a URL-safe anchor string for navigation.

    Args:
        text (str): The text to convert into an anchor.

    Returns:
        str: A cleaned anchor string.
    """
    return re.sub(r"[^a-zA-Z0-9-_]", "", text.replace(" ", "-").lower())

# Function to render and add sidebar navigation
def render_and_nav(sorted_dict: dict[str, ProjectObject]):
    """
    Renders the project list and adds navigation links in the sidebar.

    Args:
        sorted_dict (dict[str, ProjectObject]): Sorted and filtered projects.
    """
    # Sidebar Navigation
    st.sidebar.markdown("### Navigation")
    for project_name in sorted_dict.keys():
        anchor = safe_anchor(project_name)
        st.sidebar.markdown(f"- [{project_name}](#{anchor})")

    # Render Projects
    for project_name, project_object in sorted_dict.items():
        anchor = safe_anchor(project_name)
        st.markdown(f"<a id='{anchor}'></a>", unsafe_allow_html=True)
        project_object.render()



# Function to extract unique tags from projects
def get_unique_tags(projects: list[ProjectObject]):
    tags = set()
    for project in projects:
        tags.update(project.tags)
    return sorted(tags)

# Function to extract unique project types
def get_unique_project_types(projects: list[ProjectObject]):
    return sorted(set(project.project_type for project in projects))

# Function to filter projects based on selected tags and type
def filter_projects(projects: list[ProjectObject], selected_tags: set[str], selected_type: set[str]):
    filtered_projects = projects

    if selected_tags:
        filtered_projects = [
            p for p in filtered_projects if any(tag in p.tags for tag in selected_tags)
        ]

    if selected_type != "All":
        filtered_projects = [p for p in filtered_projects if p.project_type == selected_type]

    return filtered_projects

# Function to sort projects by date
def sort_projects(projects: list[ProjectObject], sort_order: str):
    reverse_sort = sort_order == "Descending"
    return sorted(projects, key=lambda x: x.date_, reverse=reverse_sort)
