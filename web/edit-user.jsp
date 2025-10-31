<div class="central-div" style="top:10%">
  <form action="controller.jsp" method="post">
    <input type="hidden" name="page" value="profile">
    <table>
      <tr>
        <td><label>First Name</label></td>
        <td><input type="text" name="fname" value="<%=user.getFirstName() %>" class="text" placeholder="First Name"></td>
      </tr>
      <tr>
        <td><label>Last Name</label></td>
        <td><input type="text" name="lname" value="<%=user.getLastName() %>" class="text" placeholder="Last Name"></td>
      </tr>

      <!-- Lock username -->
      <tr>
        <td><label>User Name</label></td>
        <td>
          <input type="text" value="<%=user.getUserName() %>" class="text" readonly
                 placeholder="User Name (locked)">
          <!-- No name="uname" so it won't post -->
        </td>
      </tr>

      <tr>
        <td><label>Email</label></td>
        <td><input type="email" name="email" value="<%=user.getEmail() %>" class="text" placeholder="Email"></td>
      </tr>

      <!-- Lock password -->
      <tr>
        <td><label>Password</label></td>
        <td>
          <input type="password" value="********" class="text" readonly
                 placeholder="Password (locked)">
          <!-- No name="pass" so it won't post -->
        </td>
      </tr>

      <tr>
        <td><label>Contact No</label></td>
        <td><input type="text" name="contactno" value="<%=user.getContact() %>" class="text" placeholder="Contact No"></td>
      </tr>
      <tr>
        <td><label>City</label></td>
        <td><input type="text" name="city" value="<%=user.getCity() %>" class="text" placeholder="City"></td>
      </tr>
      <tr>
        <td><label>Address</label></td>
        <td><input type="text" name="address" value="<%=user.getAddress() %>" class="text" placeholder="Address"></td>
      </tr>
      <tr>
        <td></td>
        <td><center><input type="submit" value="Done" class="button"></center></td>
      </tr>
    </table>
  </form>
</div>
            