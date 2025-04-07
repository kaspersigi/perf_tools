#include <boost/regex.hpp>
#include <chrono>
#include <filesystem>
#include <format>
#include <fstream>
#include <map>
#include <print>

enum class Status {
    OK,
    ERR,
};

class Elapse {
public:
    explicit Elapse(const std::string& name);
    explicit Elapse(std::nullptr_t) = delete;
    ~Elapse();

protected:
    Elapse(const Elapse&) = delete;
    Elapse(Elapse&&) = delete;
    Elapse& operator=(const Elapse&) = delete;
    Elapse& operator=(Elapse&&) = delete;

private:
    std::string _name {};
    std::chrono::high_resolution_clock::time_point _start {};
    std::chrono::high_resolution_clock::time_point _end {};
};

Elapse::Elapse(const std::string& name)
    : _name(name)
{
    _start = std::chrono::high_resolution_clock::now();
}

Elapse::~Elapse()
{
    _end = std::chrono::high_resolution_clock::now();
    std::println("{} cost time {}", _name, std::chrono::duration<double, std::milli>(_end - _start));
}

class ITraceItem {
public:
    virtual ~ITraceItem() = default;

protected:
    ITraceItem() = default;

public:
    std::string task {};
    long pid { -1 };
    long tgid { -1 };
    std::string cpu {};
    std::string delay {};
    double timestamp { 0.0 };
    std::string function {};
    std::string message {};
};

class TraceItem : public ITraceItem {
public:
    TraceItem() = default;
    virtual ~TraceItem() = default;
};

static const std::string str(R"(^ +(.+)\-(\d+) +\( *(\S+)\) +\[(\d+)\] +(\S+) +(\d+\.\d+): +([a-zA-Z0-9_]+): *(.*)$)");

auto preprocess(const std::string& path, std::map<unsigned long long, TraceItem>& trace) -> Status
{
    Elapse elapse(std::string(__func__));
    std::ifstream ifs(path);
    std::string line {};
    boost::regex pattern(str);
    boost::smatch matched_part {};
    auto status { Status::ERR };
    if (ifs.is_open()) {
        unsigned long long index { 0 };
        while (std::getline(ifs, line)) {
            bool found = boost::regex_search(line, matched_part, pattern);
            if (found) {
                TraceItem item;
                std::string task = matched_part[1];
                std::string pid = matched_part[2];
                std::string tgid = matched_part[3];
                std::string cpu = matched_part[4];
                std::string delay = matched_part[5];
                std::string timestamp = matched_part[6];
                std::string function = matched_part[7];
                std::string message = matched_part[8];

                item.task = task;
                try {
                    item.pid = std::stol(pid);
                } catch (...) {
                    std::println("[{}][{}][{}][{}][{}][{}][{}][{}]", task, pid, tgid, cpu, delay, timestamp, function, message);
                    break;
                }
                try {
                    item.tgid = tgid.compare("-----") ? std::stol(tgid) : -1;
                } catch (...) {
                    std::println("[{}][{}][{}][{}][{}][{}][{}][{}]", task, pid, tgid, cpu, delay, timestamp, function, message);
                    break;
                }
                item.cpu = cpu;
                item.delay = delay;
                item.timestamp = std::stod(timestamp);
                item.function = function;
                item.message = message;
                trace[index++] = item;
            } else {
                std::println("{}", line);
            }
        }
        status = Status::OK;
    }

    return status;
}

auto print_trace(const std::map<unsigned long long, TraceItem>& trace) -> Status
{
    Elapse elapse(std::string(__func__));
    auto status { Status::ERR };
    std::for_each(trace.cbegin(), trace.cend(), [](auto &e){ std::format("[{}][{}][{}][{}][{}][{}][{}][{}]", e.second.task, e.second.pid, e.second.tgid, e.second.cpu, e.second.delay, e.second.timestamp, e.second.function, e.second.message);});
    // std::for_each(trace.cbegin(), trace.cend(), [](auto &e){ std::println("[{}][{}][{}][{}][{}][{}][{}][{}]", e.second.task, e.second.pid, e.second.tgid, e.second.cpu, e.second.delay, e.second.timestamp, e.second.function, e.second.message);});
    status = Status::OK;

    return status;
}

auto main(int argc, char* argv[]) -> int
{
    std::map<unsigned long long, TraceItem> trace {};
    auto status { Status::ERR };
    if (!argv[1])
    {
        std::println("{}: {}", __LINE__, "please input a file path as arg!");
        return -1;
    }
    std::string perfetto_path(argv[1]);
    std::filesystem::path perfetto(perfetto_path);
    if (!std::filesystem::exists(perfetto))
    {
        std::println("{}: {} {}", __LINE__, perfetto_path, "not exist!");
        return -1;
    }
    if (!std::filesystem::is_regular_file(perfetto))
    {
        std::println("{}: {} {}", __LINE__, perfetto_path, "is not a regular file!");
        return -1;
    }
    std::string stem = perfetto.stem().string();
    std::string systrace_path = stem + ".html";
    std::filesystem::path systrace(systrace_path);
    if (!std::filesystem::exists(systrace))
    {
        std::println("{}: {} {}", __LINE__, systrace_path, "systrace not exist!");
        std::string cmd("./traceconv systrace " + perfetto_path + " " + systrace_path);
        system(cmd.c_str());
    }
    if (!std::filesystem::is_regular_file(systrace))
    {
        std::println("{}: {} {}", __LINE__, perfetto_path, "is not a regular file!");
        return -1;
    }

    status = preprocess(systrace_path, trace);
    if (Status::ERR == status) {
        return -1;
    }
    status = print_trace(trace);
    if (Status::ERR == status) {
        return -1;
    }

    return 0;
}