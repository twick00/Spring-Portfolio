<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: twick
  Date: 6/20/2018
  Time: 10:43 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>File Upload</title>
</head>
<body>
<form method="POST" enctype="multipart/form-data" action="<c:url value="/upload"/>">
    <table>
        <tr>
            <td>File To Upload:</td>
            <td><input required type="file" name="file"></td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" value="Upload"/></td>
        </tr>
    </table>
</form>
<div>
    <ul>
        <li><h3>Files:</h3></li>
        <c:choose>
            <c:when test="${not empty file}">
                ${file.name}
            </c:when>
            <c:otherwise>
                <li>No Files Found</li>
            </c:otherwise>
        </c:choose>
    </ul>
</div>
</body>
</html>
