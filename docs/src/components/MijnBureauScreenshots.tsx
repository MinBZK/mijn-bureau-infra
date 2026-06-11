import { useState } from "react";
import useBaseUrl from "@docusaurus/useBaseUrl";
import Heading from "@theme/Heading";

import styles from "./MijnBureauScreenshots.module.css";

interface Hotspot {
  x: number;
  y: number;
  targetId: string;
  label: string;
}

interface ScreenshotItem {
  id: string;
  label: string;
  icon: string;
  image: string;
  alt: string;
  description: string;
  hotspots: Hotspot[];
}

const SCREENSHOTS: ScreenshotItem[] = [
  {
    id: "bureaublad",
    label: "Bureaublad",
    icon: "🏠",
    image: "/img/screenshots/1-bureaublad.png",
    alt: "MijnBureau bureaublad overzicht",
    description: "Centraal startpunt voor al je apps, meldingen en dagelijkse taken.",
    hotspots: [{ x: 26, y: 2, targetId: "notities", label: "Bekijk Notities" }],
  },
  {
    id: "notities",
    label: "Notities",
    icon: "📝",
    image: "/img/screenshots/2-notities-files.png",
    alt: "Notities component in MijnBureau",
    description: "Maak, organiseer en deel notities veilig binnen je organisatie.",
    hotspots: [{ x: 32, y: 2, targetId: "bestanden", label: "Bekijk Bestanden" }, { x: 40, y: 31, targetId: "notities-files", label: "Bekijk Notitie" }],
  },
  {
    id: "notities-files",
    label: "Notities",
    icon: "📝",
    image: "/img/screenshots/2-notities.png",
    alt: "Notities component in MijnBureau",
    description: "Maak, organiseer en deel notities veilig binnen je organisatie.",
    hotspots: [{ x: 26, y: 2, targetId: "notities", label: "Bekijk Notities" }],
  },
  {
    id: "bestanden",
    label: "Bestanden",
    icon: "📁",
    image: "/img/screenshots/3-bestanden.png",
    alt: "Bestandenoverzicht in MijnBureau",
    description: "Beheer documenten en mappen met heldere rechtenstructuur.",
    hotspots: [{ x: 38, y: 2, targetId: "videobellen", label: "Bekijk Videobellen" }
      , { x: 35, y: 33, targetId: "powerpoint", label: "Bekijk Presentaties" }
      , { x: 35, y: 51, targetId: "excel", label: "Bekijk Spreadsheets" }
      , { x: 35, y: 62, targetId: "word", label: "Bekijk Text" }

    ],
  },
  {
    id: "powerpoint",
    label: "Presentaties",
    icon: "📊",
    image: "/img/screenshots/3-bestanden-powerpoint.png",
    alt: "PowerPoint-bestand openen in MijnBureau",
    description: "Bewerk en bekijk presentaties direct in de browser.",
    hotspots: [{ x: 32, y: 2, targetId: "bestanden", label: "Bekijk Bestanden" }],
  },
  {
    id: "excel",
    label: "Spreadsheets",
    icon: "📊",
    image: "/img/screenshots/3-bestanden-spreadsheet.png",
    alt: "Spreadsheet-bestand openen in MijnBureau",
    description: "Bewerk en bekijk spreadsheet direct in de browser.",
    hotspots: [{ x: 32, y: 2, targetId: "bestanden", label: "Bekijk Bestanden" }],
  },
  {
    id: "word",
    label: "Text",
    icon: "📊",
    image: "/img/screenshots/3-bestanden-text.png",
    alt: "Text-bestand openen in MijnBureau",
    description: "Bewerk en bekijk text bestanden direct in de browser.",
    hotspots: [{  x: 32, y: 2,  targetId: "bestanden", label: "Bekijk Bestanden" }],
  },
  {
    id: "videobellen",
    label: "Videobellen",
    icon: "📹",
    image: "/img/screenshots/4-videobellen.png",
    alt: "Videobellen binnen MijnBureau",
    description: "Start beveiligde videovergaderingen op je eigen infrastructuur.",
    hotspots: [{ x: 44, y: 2, targetId: "nextcloud", label: "Bekijk Bestanden" },
      { x: 19, y: 45, targetId: "videobellen-call", label: "Bekijk videobellen" }
    ],
  },
  {
    id: "videobellen-call",
    label: "Videobellen call",
    icon: "📹",
    image: "/img/screenshots/4-videobellen-call.png",
    alt: "Videobellen binnen MijnBureau",
    description: "Start beveiligde videovergaderingen op je eigen infrastructuur.",
    hotspots: [{ x: 38, y: 2, targetId: "videobellen", label: "Bekijk Videobellen" }],
  },

  {
    id: "nextcloud",
    label: "Bestanden",
    icon: "📁",
    image: "/img/screenshots/5-nextcloud.png",
    alt: "Nextcloud integratie in MijnBureau",
    description: "Deel bestanden en werk samen in teams via Nextcloud.",
    hotspots: [{ x: 51, y: 2, targetId: "spreadsheet", label: "Bekijk Spreadsheet" }],
  },
  {
    id: "spreadsheet",
    label: "Spreadsheet",
    icon: "📈",
    image: "/img/screenshots/6-spreadsheet.png",
    alt: "Spreadsheet bewerken in MijnBureau",
    description: "Analyseer en bewerk data samen in realtime via Grist.",
    hotspots: [{ x: 58, y: 2, targetId: "ai-assistant", label: "Bekijk AI Assistent" }],
  },
  {
    id: "ai-assistant",
    label: "AI Assistent",
    icon: "🤖",
    image: "/img/screenshots/7-ai-assistant.png",
    alt: "AI Assistant in MijnBureau",
    description: "Gebruik AI-ondersteuning in een soevereine omgeving zonder datadeling.",
    hotspots: [{ x: 63, y: 2, targetId: "chat", label: "Bekijk Chat" }],
  },
  {
    id: "chat",
    label: "Chat",
    icon: "💬",
    image: "/img/screenshots/8-chat.png",
    alt: "Chat functionaliteit in MijnBureau",
    description: "Communiceer veilig via kanalen en directe berichten.",
    hotspots: [{ x: 2, y: 2, targetId: "bureaublad", label: "Back to Bureaublad" }],
  },
];

const SIDEBAR_SCREENSHOTS = SCREENSHOTS.filter(
  (item) => item.id !== "powerpoint" && item.id !== "videobellen-call" && item.id !== "notities-files" && item.id !== "excel" && item.id !== "word",
);

export default function MijnBureauScreenshots(): React.JSX.Element {
  const [activeId, setActiveId] = useState<string>(SCREENSHOTS[0].id);

  const activeScreenshot =
    SCREENSHOTS.find((item) => item.id === activeId) ?? SCREENSHOTS[0];

  const imageSrc = useBaseUrl(activeScreenshot.image);

  return (
    <section className={styles.section}>
      <div className="container">
        <div className={styles.header}>
          <Heading as="h2">MijnBureau in Action</Heading>
          <p className={styles.subtitle}>
            Experience the posibilities
          </p>
        </div>

        <div className={styles.layout}>
          <div className={styles.sidebar}>
            <ul className={styles.tabList} role="tablist" aria-label="Onderdelen">
              {SIDEBAR_SCREENSHOTS.map((item) => {
                const isActive = item.id === activeId;
                return (
                  <li key={item.id} role="presentation">
                    <button
                      type="button"
                      className={isActive ? styles.tabActive : styles.tab}
                      onClick={() => setActiveId(item.id)}
                      role="tab"
                      aria-selected={isActive}
                      aria-controls={`panel-${item.id}`}
                      id={`tab-${item.id}`}
                    >
                      <span className={styles.tabIcon}>{item.icon}</span>
                      <span className={styles.tabText}>
                        <strong>{item.label}</strong>
                        {isActive && (
                          <span className={styles.tabDesc}>{item.description}</span>
                        )}
                      </span>
                      <span className={styles.tabArrow} aria-hidden="true">›</span>
                    </button>
                  </li>
                );
              })}
            </ul>
          </div>

          <div
            className={styles.previewWrapper}
            role="tabpanel"
            id={`panel-${activeScreenshot.id}`}
            aria-labelledby={`tab-${activeScreenshot.id}`}
          >
            <div className={styles.imageContainer}>
              <img
                key={activeScreenshot.id}
                src={imageSrc}
                alt={activeScreenshot.alt}
                className={styles.image}
                loading="lazy"
              />

              {activeScreenshot.hotspots.map((spot) => (
                <button
                  key={spot.targetId}
                  type="button"
                  className={styles.hotspot}
                  style={{ left: `${spot.x}%`, top: `${spot.y}%` }}
                  onClick={() => setActiveId(spot.targetId)}
                  aria-label={spot.label}
                  title={spot.label}
                >
                  <span className={styles.hotspotPulse} aria-hidden="true" />
                  <span className={styles.hotspotCore} aria-hidden="true" />
                </button>
              ))}
            </div>

            <div className={styles.progressDots} aria-hidden="true">
              {SCREENSHOTS.map((s) => (
                <button
                  key={s.id}
                  type="button"
                  className={s.id === activeId ? styles.dotActive : styles.dot}
                  onClick={() => setActiveId(s.id)}
                  aria-label={`Ga naar ${s.label}`}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
