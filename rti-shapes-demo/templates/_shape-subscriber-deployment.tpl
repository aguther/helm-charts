{{ define "shape-subscriber-pod" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .releaseName }}-shape-subscriber-{{ .shapeKind | lower }}
  labels:
    app: shape-subscriber
    release: {{ .releaseName }}
    shapeKind: {{ .shapeKind | upper }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shape-subscriber
      release: {{ .releaseName }}
      shapeKind: {{ .shapeKind | upper }}
  template:
    metadata:
      name: {{ .releaseName }}-shape-subscriber-{{ .shapeKind | lower }}
      labels:
        app: shape-subscriber
        release: {{ .releaseName }}
        shapeKind: {{ .shapeKind | upper }}
    spec:
      containers:
        - name: {{ .releaseName }}-shape-subscriber
          image: {{ .imageCredentialsRegistry }}/{{ .imageName }}:{{ .imageTag }}
          resources:
            requests:
              cpu: {{ quote .requestsCpu }}
              memory: {{ quote .requestsMemory }}
            limits:
              cpu: {{ quote .limitsCpu }}
              memory: {{ quote .limitsMemory }}
          args:
            - "com.github.aguther.dds.examples.shape.ShapeSubscriber"
            - "--shape"
            - "$(SHAPE_KIND)"
          env:
            - name: SHAPE_KIND
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['shapeKind']
            - name: NDDS_DISCOVERY_PEERS
              value: "rtps@udpv4://$(RTI_CLOUD_DISCOVERY_SERVICE_SERVICE_HOST):$(RTI_CLOUD_DISCOVERY_SERVICE_SERVICE_PORT)"
          volumeMounts:
            - name: {{ .releaseName }}-shape-subscriber
              mountPath: /app/USER_QOS_PROFILES.xml
              subPath: USER_QOS_PROFILES.xml
          ports:
            - containerPort: 7400
              protocol: "UDP"
              name: "rtps2-disc-mult"
            - containerPort: 7401
              protocol: "UDP"
              name: "rtps2-disc-uni"
            - containerPort: 7410
              protocol: "UDP"
              name: "rtps2-data-mult"
            - containerPort: 7411
              protocol: "UDP"
              name: "rtps2-data-uni"
      imagePullSecrets:
        - name: {{ .releaseName }}-{{ .imageCredentialsName | lower }}
      volumes:
        - name: {{ .releaseName }}-shape-subscriber
          configMap:
            name: {{ .releaseName }}-dds-examples
      restartPolicy: Always
{{ end }}
