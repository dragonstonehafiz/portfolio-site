from utils.ProjectObject import ProjectObject
import streamlit as st
import re

def CreateConnectWithMe():
    st.sidebar.markdown("### Links")
    st.sidebar.markdown("[![GitHub](https://img.shields.io/badge/GitHub-%2312100E.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/dragonstonehafiz)")
    st.sidebar.markdown("[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230A66C2.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/muhdhafizabdulhalim/)")
    st.sidebar.markdown("[![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@hafiz8325)")

def CreateTagList(projects: dict[str, ProjectObject]) -> set[str]:
    """
    Takes a dictionary of project data and creates a set of unique tags
    """
    # Tag Filtering
    all_tags = set()
    for project in projects.values():
        if project.tags:
            all_tags.update(project.tags)

    return sorted(all_tags)

def CreateSidebar(all_tags: set[str]):
    CreateConnectWithMe()
    
    # Allow user to select sorting order
    sort_order = st.sidebar.radio("Sort by Year", options=["Descending", "Ascending"])

    # Determine sorting direction based on user choice
    reverse_sort = True if sort_order == "Descending" else False

    # Add a multiselect widget to filter projects by tags
    selected_tags = st.sidebar.multiselect("Filter by Tags", options=all_tags)

    return reverse_sort, selected_tags

def CreateSortedList(projects: dict[str, ProjectObject], selected_tags: set[str], reverse_sort: bool):
    # Sort projects by year based on the selected order
    sorted_sections = {
        name: project
        for name, project in sorted(
            projects.items(),
            key=lambda item: item[1].date_,  # Sort by the 'date' attribute of the project
            reverse=reverse_sort  # True for descending, False for ascending
        )
    }

    # Filter projects based on the selected tags
    filtered_sections = {
        name: project
        for name, project in sorted_sections.items()
        if not selected_tags or (project.tags and any(tag in selected_tags for tag in project.tags))
    }

    return filtered_sections

def safe_anchor(text):
    return re.sub(r"[^a-zA-Z0-9-_]", "", text.replace(" ", "-").lower())

def RenderAndNavigation(sorted_dict: dict):
    # Add navigation links to the sidebar
    st.sidebar.markdown("### Navigation")
    for project_name in sorted_dict.keys():
        # Create a clickable link to each section in the sidebar
        anchor = safe_anchor(project_name)
        markdown = f"- [{project_name}](#{anchor})"
        st.sidebar.markdown(markdown)

    # Render the filtered projects with anchor IDs
    for project_name, project_object in sorted_dict.items():
        # Add an anchor for the section
        markdown = f"<a id='{anchor}'></a>"
        st.markdown(markdown, unsafe_allow_html=True)
        # print(markdown)
        project_object.render()

