<%-- 
    Document   : editPublication
    Created on : Aug 8, 2017, 12:30:24 PM
    Author     : chee
--%>
<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://srs.slac.stanford.edu/time" prefix="time"%>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<script src="js/jquery-1.11.1.min.js"></script>
<script src="js/jquery.validate.min.js"></script>

<%@attribute name="paperid" required="true"%>
<%@attribute name="swgid" required="true"%>

<c:set var="paperid" value="${param.paperid}"/>
<c:set var="swgid" value="${param.swgid}"/>

<c:set var="paperleads" value="paper_leads_${paperid}"/> 
 <sql:query var="pubtypes">
     select pubtype from descpub_publication_types order by pubtype
 </sql:query>

 <sql:query var="pubs">
  select paperid, state, title, short_title, journal, pubtype, summary, to_char(added,'yyyy-mon-dd') added, to_char(date_modified,'yyyy-mon-dd') moddate, builder_eligible, keypub,
  pb_reader_approved, arxiv, published_reference, project_id, short_title from descpub_publication where paperid = ?
    <sql:param value="${paperid}"/>
 </sql:query>
    
<sql:query var="states">
    select state from descpub_publication_states order by state
</sql:query>
    
    <%--
<sql:query var="wgs" >
    select wg.name, wg.id, wg.convener_group_name, wg.profile_group_name from descpub_project_swgs jo join descpub_swg wg on jo.swg_id = wg.id
    where jo.project_id = ?
    <sql:param value="${pubs.rows[0].project_id}"/>
</sql:query> --%>
    
<h3>DESC-${param.paperid} Title: ${pubs.rows[0].title} </h3>
    Project Id: <a href="show_project.jsp?projid=${pubs.rows[0].project_id}">${pubs.rows[0].project_id}</a> &nbsp; &nbsp; Added: ${pubs.rows[0].added}
    <c:if test="${!empty pubs.rows[0].moddate}">
        &nbsp; &nbsp;Last Modified: ${pubs.rows[0].moddate} &nbsp; &nbsp; &nbsp; &nbsp;
    </c:if>
        [ Placeholder for link to internal review ]
    <p/> 
    
   <form action="editPublication.jsp">  
   <input type="hidden" name="paperid" value="${paperid}"/> 
   <input type="hidden" name="swgid" value="${swgid}"/> 
   Title: <br/> <input type="text" value="${pubs.rows[0].title}" size="35" name="title" required/>
              
   <p/>
   Short Title: <br/> <input type="text" value="${pubs.rows[0].short_title}" size="35" name="short_title"/>
   
   <p/>
   Brief Summary: <br/>
   <textarea name="summary" rows="10" cols="60" required>${pubs.rows[0].SUMMARY}</textarea><br/>
   <p/>
   State: 
   <select name="state" id="state">
       <c:forEach var="sta" items="${states.rows}">
           <c:if test="${fn:startsWith(pubs.rows[0].state,sta.state)}">
               <option value="${sta.state}" selected>${sta.state}</option>
           </c:if>
           <c:if test="${!fn:startsWith(pubs.rows[0].state,sta.state)}">
               <option value="${sta.state}">${sta.state}</option>
           </c:if>
       </c:forEach>
   </select>
  
   <p/>
   Pubtype: 
   <select name="pubtype" id="pubtype">
        <c:forEach var="ptype" items="${pubtypes.rows}">
            <option value="${ptype.pubtype}" <c:if test="${pubs.rows[0].pubtype == ptype.pubtype}">selected</c:if>  >${ptype.pubtype}</option>
        </c:forEach>
    </select>
  
   <p/>
    Builder Eligible: 
   <select name="builder_eligible" id="builder_eligible" required>
       <option value=""></option>
       <option value="Y" <c:if test="${pubs.rows[0].builder_eligible == 'Y'}">selected</c:if> >Yes</option>
       <option value="N" <c:if test="${pubs.rows[0].builder_eligible == 'N'}">selected</c:if> >No </option>
   </select>
   <p/>
   
   Key Paper: 
   <select name="keypub" id="keypub" required>
       <option value=""></option>
       <option value="Y" <c:if test="${pubs.rows[0].keypub == 'Y'}">selected</c:if> >Yes</option>
       <option value="N" <c:if test="${pubs.rows[0].keypub == 'N'}">selected</c:if> >No</option>
   </select>
    <p/>
   
   <c:if test="${!fn:startsWith(pubs.rows[0].pubtype,'External')}">
       Passed internal review: 
       <select name="pb_reader_approved" id="pb_reader_approved" required>
           <option value=""></option>
           <option value="Y" <c:if test="${pubs.rows[0].pb_reader_approved == 'Y'}">selected</c:if> >Yes</option>
           <option value="N" <c:if test="${pubs.rows[0].pb_reader_approved == 'N'}">selected</c:if> >No</option>
       </select>
       <p/>

       Journal: <input type="text" name="journal" value="${pubs.rows[0].JOURNAL}" size="25" name="journal"/>
         <p/>

       arXiv number: <input type="text" value="${pubs.rows[0].ARXIV}" size="25" name="arxiv"/>
       <p/>
       Published Reference: <input type="text" value="${pubs.rows[0].PUBLISHED_REFERENCE}" size="25" name="published_reference"/>
   </c:if>
   <p/>
   <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,paperleads)}">
   <input type="submit" value="UpdatePub" name="action" />
   <input type="hidden" value="formSubmitted" name="formSubmitted"/>
   </c:if>
</form>  
 
 