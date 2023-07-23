import { useEffect, useState } from "react";
import axios from "axios";
import "./App.css";
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  Modal,
  Container,
  Box,
} from "@mui/material";
import { FcGallery } from "react-icons/fc";
import { AiOutlineSelect } from "react-icons/ai";

function App() {
  const [file, setFile] = useState(null);
  const [result, setResult] = useState(null);
  const [classification, setClassification] = useState(null);
  const [openModal, setOpenModal] = useState(false);
  const [isButtonDisabled, setIsButtonDisabled] = useState(false);
  const [buttonVisible, setButtonVisible] = useState(true);
  const [classificationConfidence, setClassificationConfidence] =
    useState(null);

  useEffect(() => {
    if (file) {
      uploadImage();
    }
  }, [file]);

  const handleFileChange = (event) => {
    setClassification(null);
    setClassificationConfidence(null);
    setResult(null);
    setFile(event.target.files[0]);
    setOpenModal(false);
  };

  const uploadImage = () => {
    const formData = new FormData();
    formData.append("image", file);

    axios
      .post("http://127.0.0.1:5000/upload", formData)
      .then((response) => response.data)
      .then((data) => {
        setResult(data);
        if (data.message === "retinal") {
          setClassification(null); // Reset classification if message is retinal
        }
      })
      .catch((error) => {
        console.error("Error in request:", error);
      });
  };

  const classifyImage = () => {
    const formData = new FormData();
    formData.append("image", file);
    setButtonVisible(false);

    axios
      .post("http://localhost:5000/uploadS", formData)
      .then((response) => response.data)
      .then((classificationData) => {
        setClassification(classificationData.message);
        setClassificationConfidence(classificationData.confidence);
      })
      .catch((error) => {
        console.error("Error in Classification Request:", error);
      });
  };

  const handleOpenModal = () => {
    setOpenModal(true);
  };

  const handleCloseModal = () => {
    setOpenModal(false);
  };

  // const handleGalleryOption = () => {
  //   // Handle gallery option here
  //   setOpenModal(false);
  //   setIsButtonDisabled(true);
  // };

  // const handleCameraOption = () => {
  //   // Handle camera option here
  //   setOpenModal(false);
  //   setIsButtonDisabled(true);
  // };

  return (
    <Box
      style={{
        backgroundColor: "#123456",
        height: "100vh",
      }}
    >
      <Modal open={openModal} onClose={handleCloseModal}>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "100%",
          }}
        >
          <Card style={{ width: "300px", backgroundColor: "#123456" }}>
            <CardContent>
              <Typography
                variant="h6"
                align="center"
                gutterBottom
                color="white"
              >
                Select Image
              </Typography>
              <Grid container spacing={2} justifyContent="center">
                <Grid item>
                  <label htmlFor="gallery-input">
                    <input
                      id="gallery-input"
                      type="file"
                      name="image"
                      accept="image/*"
                      onChange={handleFileChange}
                      style={{
                        display: "none",
                      }}
                    />
                    <Button
                      variant="contained"
                      component="span"
                      endIcon={<FcGallery />}
                      loading
                    >
                      Gallery
                    </Button>
                  </label>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </div>
      </Modal>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Diabetic Retinopathy Detection
          </Typography>
        </Toolbar>
      </AppBar>
      <Box
        sx={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        <Container>
          <Container
            maxWidth="md"
            sx={{
              display: "flex",
              justifyContent: "center",
              marginTop: "4rem",
            }}
          >
            <Button
              variant="contained"
              onClick={handleOpenModal}
              disabled={isButtonDisabled}
            >
              Select
            </Button>
          </Container>

          {file && (
            <div
              style={{
                marginTop: "1rem",
                textAlign: "center",
              }}
            >
              <Typography variant="body1">
                {/* Selected Image: {file.name} */}
              </Typography>
              <img
                src={URL.createObjectURL(file)}
                alt="Selected"
                style={{
                  marginTop: "1rem",
                  backgroundColor: "white",
                  height: "400px",
                }}
              />
              <Button></Button>
            </div>
          )}
        </Container>
        <Container>
          {result && (
            <>
              <Typography
                variant="h3"
                align="center"
                mt={3}
                color="#ffffff"
                fontFamily="sans-serif"
                // fontSize="62px"
                fontWeight="700"
                // lineHeight=" 72px"
                margin=" 0 0 24px"
                textAlign=" center"
                textTransform="uppercase"
              >
                {result?.message === "retinal"
                  ? "Retinal Image"
                  : "Non-Retinal Image"}
              </Typography>

              <Typography
                // variant="h3"
                align="center"
                mt={1}
                color="#ffffff"
                fontFamily="sans-serif"
                fontSize="36px"
                fontWeight="800px"
                lineHeight="36px"
                margin="0 0 24px"
                textAlign="center"
              >
                Confidence: {result?.confidence}
              </Typography>
            </>
          )}
          {result?.message === "retinal" && (
            <Grid
              container
              justifyContent="center"
              marginTop="3rem"
              marginBottom="3rem"
            >
              {buttonVisible && (
                <Button variant="contained" onClick={classifyImage}>
                  Classify
                </Button>
              )}
            </Grid>
          )}
          {classification && (
            <>
              <Typography
                variant="h3"
                align="center"
                mt={3}
                color="#ffffff"
                fontFamily="sans-serif"
                // fontSize="62px"
                fontWeight="700"
                // lineHeight=" 72px"
                margin=" 0 0 24px"
                textAlign=" center"
                textTransform="uppercase"
              >
                Classification: {classification}
              </Typography>
              <Typography
                variant="h3"
                align="center"
                mt={1}
                color="#ffffff"
                fontFamily="sans-serif"
                fontSize="36px"
                fontWeight="800px"
                lineHeight="36px"
                margin="0 0 24px"
                textAlign="center"
              >
                Confidence: {classificationConfidence}
              </Typography>
            </>
          )}
        </Container>
      </Box>
    </Box>
  );
}

export default App;
