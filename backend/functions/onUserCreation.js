/*
  This function will run after a user is created and is called with an object representing that user.

  This function runs as a System user and has full access to Services, Functions, and MongoDB Data.

  Example below:

  exports = ({ user }) => {
    // use collection that Custom User Data is configured on
    const collection = context.services.get("<SERVICE_NAME>").db("<DB_NAME>").collection("<COLL_NAME>");

    // insert custom data into collection, using the user id field that Custom User Data is configured on
    const doc = collection.insertOne({ <USER_ID_FIELD>: user.id, name: user.data.name });
  };
*/

exports = async (user) => {
    const customUserDataCollection = context.services
     .get("mongodb-atlas")
     .db("CorrectInk")
     .collection("users");
     
     try {
     await customUserDataCollection.insertOne({
       // Save the user's account ID to your configured user_id_field
       user_id: user.userId,
       firstname: user.firstname,
       lastname: user.lastname,
       study_streak: user.study_streak,
     });
   } catch (e) {
     console.error(`Failed to create custom user data document for user:${user.id}`);
     throw e
   }
   return;
 };