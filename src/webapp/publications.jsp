<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>

<title>LSST-DESC Publication System (Chee Version)</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"> -->
<link rel="stylesheet" href="css/pub-css"/>
<body>

<sql:query var="mems">
    select me.firstname, me.lastname, hi.position, us.username, pm.activestatus, ii.institution, ro.projrole
    from um_member me join um_project_members pm on pm.memidnum=me.memidnum
    join um_member_username us on me.memidnum=us.memidnum
    join um_member_institution ii on ii.memidnum=me.memidnum and ii.current_inst='Y'
    join um_member_inst_history hi on hi.meminstidnum=ii.meminstidnum and hi.currentposition='Y'
    join um_projmem_history ro on ro.projmemidnum=pm.projmemidnum
    where pm.project=?
<sql:param value="${appVariables.experiment}"/>
</sql:query>
    
<!-- Sidebar -->
<div class="pub-sidebar pub-light-grey pub-bar-block" style="width:10%">
  <h3 class="pub-bar-item">Menu</h3>
  <a href="#" class="pub-bar-item pub-button">Speakers Bureau</a>
  <a href="#" class="pub-bar-item pub-button">Publications Board</a>
  <a href="#" class="pub-bar-item pub-button">My Profile</a>
</div>

<!-- Page Content -->
<div style="margin-left:10%">

    <div class="w3-container w3-light-grey">
      <h3>Users</h3>
      <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/newCollaborator.jsp">create member</a>
    </div>
    <div style="margin:5px">
     <a href="#index_A">A</a>&nbsp;<a href="#index_B">B</a>&nbsp;<a href="#index_C">C</a>&nbsp;<a href="#index_D">D</a>&nbsp;<a href="#index_E">E</a>&nbsp;<a href="#index_F">F</a>&nbsp;<a href="#index_G">G</a>&nbsp;<a href="#index_H">H</a>&nbsp;I&nbsp;<a href="#index_J">J</a>&nbsp;<a href="#index_K">K</a>&nbsp;<a href="#index_L">L</a>&nbsp;<a href="#index_M">M</a>&nbsp;<a href="#index_N">N</a>&nbsp;<a href="#index_O">O</a>&nbsp;<a href="#index_P">P</a>&nbsp;<a href="#index_Q">Q</a>&nbsp;<a href="#index_R">R</a>&nbsp;<a href="#index_S">S</a>&nbsp;<a href="#index_T">T</a>&nbsp;<a href="#index_U">U</a>&nbsp;<a href="#index_V">V</a>&nbsp;<a href="#index_W">W</a>&nbsp;X&nbsp;<a href="#index_Y">Y</a>&nbsp;<a href="#index_Z">Z</a>&nbsp;
    </div>

    <div>
        <display:table class="datatable" id="IRow" name="${mems.rows}" defaultsort="1">
        </display:table>
    </div>
    
    <div class="w3-container">
    <p>The sidebar with is set with "style="width:25%".</p>
    <p>The left margin of the page content is set to the same value.</p>
    </div>

</div>
      
    

</body>
</html>
    
    
</html>
